require 'rack/test'

module Rack
  class MockSession
    alias_method :request_original, :request
    def request(uri, env)
      EM.synchrony do
        request_original uri, env
        EM.stop
      end
    end
  end
end