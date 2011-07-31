Sinatra::Synchrony
===

Sinatra + EM-Synchrony - fast, concurrent web applications with no callbacks!

Sinatra::Synchrony is a very small extension for Sinatra that dramatically improves the concurrency of your web application. Powered by [EventMachine](https://github.com/eventmachine/eventmachine) and [EM-Synchrony](https://github.com/igrigorik/em-synchrony), it increases the number of clients your application can serve per process when you have a lot of slow IO calls (like HTTP calls to external APIs). Because it uses [Fibers](http://www.ruby-doc.org/core-1.9/classes/Fiber.html) internally to handle concurrency, no callback gymnastics are required! Just develop as if you were writing a normal Sinatra web application, use non-blocking libraries (see below) and you're all set!

How it works
---

* Loads [EventMachine](https://github.com/eventmachine/eventmachine) and [EM-Synchrony](https://github.com/igrigorik/em-synchrony). Requires app server with EventMachine and Ruby 1.9 support (Thin, Rainbows!, Heroku).
* Inserts the [Rack::FiberPool](https://github.com/mperham/rack-fiber_pool) middleware, which automatically provides a Fiber for each incoming request, allowing EM-Synchrony to work.
* Adds [em-http-request](https://github.com/igrigorik/em-http-request), which you can use with EM::Synchrony to do concurrent HTTP calls to APIs! Or if you'd rather use a different client:
* Patches TCPSocket via EM-Synchrony. Any software that uses this (such as an HTTP Client that uses Net::HTTP) can run without blocking IO. [RestClient](https://github.com/archiloque/rest-client) works great with this!
* Patches Rack::Test so that it runs your tests within an EventMachine. Just test the same way you did before and it should just work.
* Patches Resolv via [em-resolv-replace](https://github.com/mperham/em-resolv-replace), enabling non-blocking DNS lookups magically, the way David Bowie would want it.

What it doesn't do (yet)
---

Provide non-blocking drivers for everything. Right now the focus was to deal with the biggest concurrency problem for most apps, which is API calls to external websites. You don't have to make _everything_ non-blocking to speed up applications with this approach, which is the important thing to understand. For example, if your database access is under ten milliseconds, it's not as bad as an API call to an external web site that takes a few seconds. There are numerous non-blocking drivers available however, check out the [Protocol Implementations](https://github.com/eventmachine/eventmachine/wiki/Protocol-Implementations) page on the [EventMachine GitHub Wiki](https://github.com/eventmachine/eventmachine/wiki) for a full list. I would personally like to see plug-and-play drivers implemented for the major three ORMs (ActiveRecord, DataMapper, Sequel), because then I could simply drop them into this gem and you'd be non-blocking without requiring any special changes. For most of the web applications I work on, this would be all I need to eliminate my blocking IO problems forever!

Installation
---
Install the gem:

    gem install sinatra-synchrony

Register with Sinatra __at the top, before any other middleware or plugins are loaded__:

    require 'sinatra/base'
    require 'sinatra/synchrony'
    class App < Sinatra::Base
      register Sinatra::Synchrony
    end

If you are developing with a classic style app, just require the gem and it will automatically load:

    require 'sinatra'
    require 'sinatra/synchrony'
    
    get '/' do
      'Sinatra::Synchrony is loaded automatically in classic mode, nothing needed'
    end

Net::HTTP / TCPSocket
---
If you're using anything based on TCPSocket (such as Net::HTTP, which is used by many things), you can replace the native Ruby TCPSocket with one that supports EventMachine and allows for concurrency:

    Sinatra::Synchrony.patch_tcpsocket!

This will allow you to use things like [RestClient](https://github.com/archiloque/rest-client) without any changes:

    RestClient.get 'http://google.com'

This is not perfect though - the TCPSocket overload doesn't currently support SSL and will throw an exception. This is more for when you have ruby libraries that use Net::HTTP and you want to try something. If you intend to do HTTP requests, I strongly recommend using [Faraday](https://github.com/technoweenie/faraday) instead, which has support for [EM-HTTP-Request](https://github.com/igrigorik/em-http-request).

Please encourage Ruby library developers to use (or at least support) Faraday instead of Net::HTTP. Aside from the inability to be concurrent natively, it's a pretty weird and crappy interface, which makes it harder to replace it with something better.

Tests
---
Add this to the top of your test file:

    Sinatra::Synchrony.patch_tests!

Then just write your tests as usual, and all tests will be run within EventMachine. You must be in the __test__ environment so that Sinatra will not load Rack::FiberPool.

Benchmarks
---
It's pretty fast!

    class App < Sinatra::Base
      register Sinatra::Synchrony
      get '/' do
        'Hello World!'
      end
    end

run with rackup -s thin:

    $ ab -c 50 -n 2000 http://127.0.0.1:9292/
    ...
    Requests per second:    3102.30 [#/sec] (mean)
    Time per request:       16.117 [ms] (mean)
    Time per request:       0.322 [ms] (mean, across all concurrent requests)

    Connection Times (ms)
                  min  mean[+/-sd] median   max
    Connect:        0    0   0.1      0       1
    Processing:     5   16   7.7     13      38
    Waiting:        3   13   7.0     10      35
    Total:          6   16   7.7     13      38

Let's try a simple blocking IO example to prove it works. 100 hits to google.com:

    require 'rest-client'
    
    class App < Sinatra::Base
      register Sinatra::Synchrony
      get '/' do
        # Using EventMachine::HttpRequest
        # EM::Synchrony.sync(EventMachine::HttpRequest.new('http://google.com').get).response

        # Using RestClient, which gets concurrency via patched TCPSocket, no changes required!
        RestClient.get 'http://google.com'
      end 
    end

    $ ab -c 100 -n 100 http://127.0.0.1:9292/
    ...
    Time taken for tests:   1.270 seconds
    
For a perspective, this operation takes __33 seconds__ without this extension. That's __26x__ faster!

Geoloqi
---
This gem was designed to help us develop faster games and internal applications for [Geoloqi](http://geoloqi.org): a private, real-time mobile and web platform for securely sharing location data. We wanted to share with you how we deal with concurrency issues, and also make it easy to utilize this for our other projects. One of these projects is our recently released [Geoloqi ruby adapter](http://github.com/kyledrake/geoloqi-ruby), which utilizes [Faraday](http://github.com/technoweenie/faraday) and sinatra-synchrony to provide massive concurrency with almost no changes required to your code. Geoloqi is production ready right now, and we have a lot of major features and enhancements in store for this summer. Keep an eye on us! We won't disappoint.

TODO / Thoughts
---
* This is fairly new, though we are using it in production without any problems. Test before deploying anything with it.
* Provide better method for patching Rack::Test that's less fragile to version changes. This is a big priority and I intend to improve this. Pull requests here welcome!
* Research way to run tests with Rack::FiberPool enabled.
* There is work underway to make this a Rack middleware, and integrate that middleware with this plugin. That way, many other frameworks can take advantage of this. There is also work exploratory work to provide support for non-EventMachine Reactor pattern implementations with this approach, but it's beyond the scope of this extension.

Author
---
* [Kyle Drake](http://kyledrake.net)

Thanks
---
* [Ilya Grigorik](http://www.igvita.com) and [PostRank](http://www.postrank.com) for their amazing work on em-synchrony, em-http-request, and countless articles explaining this.
* [Mike Perham](http://www.mikeperham.com) and [Carbon Five](http://carbonfive.com). For rack-fiber_pool, em-resolv-replace, and many blog posts and presentations on this.
* [Konstantin Haase](http://rkh.im/) for session overload suggestion.
* [Steeve Morin](http://github.com/steeve)
* The many Sinatra developers that liberated me from framework hell, and EventMachine developers that liberated me from blocking IO hell.
