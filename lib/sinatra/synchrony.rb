require 'sinatra/base'
require 'rack/fiber_pool'
require 'async-rack'
require 'eventmachine'
require 'em-http-request'
require 'em-synchrony'
require 'em-resolv-replace'
require 'net/http'

original_verbosity = $VERBOSE
$VERBOSE = nil
TCPSocket = EventMachine::Synchrony::TCPSocket
$VERBOSE = original_verbosity

module Sinatra
  module Synchrony
    def self.registered(app)
      app.use Rack::FiberPool unless app.test?
    end
  end
  register Synchrony
end