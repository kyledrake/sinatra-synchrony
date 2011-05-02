Sinatra::Synchrony
===

Sinatra::Synchrony is a glue extension for Sinatra that enables radically improved asynchronous concurrency with [EventMachine](https://github.com/eventmachine/eventmachine) and [EM-Synchrony](https://github.com/igrigorik/em-synchrony). It dramatically increases the number of clients your application can serve per process when you have a lot of slow IO calls (like HTTP calls to external APIs). Because it uses [Fibers](http://www.ruby-doc.org/core-1.9/classes/Fiber.html) internally to handle concurrency, no callback gymnastics are required! Just develop as if you were writing a normal Sinatra web application, use non-blocking libraries (see below) and you're all set!

How it works
---

* Loads [EventMachine](https://github.com/eventmachine/eventmachine) and [EM-Synchrony](https://github.com/igrigorik/em-synchrony). Requires app server with EventMachine and Ruby 1.9 support (Thin, Rainbows!, Heroku).
* Inserts the [Rack::FiberPool](https://github.com/mperham/rack-fiber_pool) middleware, which automatically provides a Fiber for each incoming request, allowing EM-Synchrony to work.
* Inserts [async-rack](https://github.com/rkh/async-rack/tree/master/lib/async_rack), which makes Rack's middleware more async friendly.
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

    require 'sinatra/synchrony'
    class App < Sinatra::Base
      register Sinatra::Synchrony
    end
    
One important thing: __do not use Sinatra's internal session code__. So no "enable :sessions". Instead, enable the sessions directly via the [Rack::Session::Cookie](http://rack.rubyforge.org/doc/classes/Rack/Session/Cookie.html) middleware (there is no consequence to doing this, Sinatra does the same thing under the hood.. it just does it in the wrong load order):

    class App < Sinatra::Base
      register Sinatra::Synchrony
      use Rack::Session::Cookie, :secret => 'CHANGE ME TO SOMETHING!'
    end

Tests
---

Just write your tests as usual, and they will be run within an EventMachine reactor. You must be in the __test__ environment so that Sinatra will no load Rack::FiberPool during testing.

TODO / Thoughts
---
* Provide better method for patching Rack::Test that's less fragile to version changes. This is a big priority and I intend to improve this. Pull requests here welcome!
* Research way to run tests with Rack::FiberPool enabled.

Author
---
* [Kyle Drake](http://kyledrake.net)

Thanks
---
* [Ilya Grigorik](http://www.igvita.com) and [PostRank](http://www.postrank.com) for their amazing work on em-synchrony, em-http-request, and countless articles explaining this.
* [Mike Perham](http://www.mikeperham.com) and [Carbon Five](http://carbonfive.com). For rack-fiber_pool, em-resolv-replace, and many blog posts and presentations on this.
* [Konstantin Haase](http://rkh.im/) for async-rack and his many contributions to Sinatra.
* The many developers that helped Sinatra and EventMachine become a real force for concurrent programming.