require 'rack/test'
# Monkeypatch to provide EM within tests.
# If you have a better approach, please send a pull request!

module Rack
  class MockSession
    def request(uri, env)
      env["HTTP_COOKIE"] ||= cookie_jar.for(uri)
      @last_request = Rack::Request.new(env)
      EM.synchrony do
        status, headers, body = @app.call(@last_request.env)
        @last_response = MockResponse.new(status, headers, body, env["rack.errors"].flush)
        body.close if body.respond_to?(:close)
        cookie_jar.merge(last_response.headers["Set-Cookie"], uri)
        @after_request.each { |hook| hook.call }
        if @last_response.respond_to?(:finish)
          @last_response.finish
        else
          @last_response
        end
        EM.stop
      end
    end
  end
end
