require 'sinatra/base'
require 'rack/fiber_pool'
require 'eventmachine'
require 'em-http-request'
require 'em-synchrony'
require 'em-resolv-replace'
require 'async-rack'

module Sinatra
  module Synchrony
    def setup_sessions(builder)
      builder.use Rack::FiberPool unless test?
      super
    end

    class << self
      def patch_tests!
        require 'sinatra/synchrony/mock_session'
      end

      def overload_tcpsocket!
        require 'sinatra/synchrony/tcpsocket'
      end
    end
  end
  register Synchrony
end