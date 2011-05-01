ENV['RACK_ENV'] = 'test'
require File.join(File.join(File.expand_path(File.dirname(__FILE__))), '..', 'lib', 'sinatra', 'synchrony')
require File.join(File.join(File.expand_path(File.dirname(__FILE__))), '..', 'lib', 'rack', 'test_synchrony')
require 'minitest/autorun'
require 'wrong/adapters/minitest'
Wrong.config.alias_assert :expect

def mock_app(base=Sinatra::Base, &block)
  @app = Sinatra.new(base, &block)
  @app.set :environment, :test
  @app.disable :show_exceptions
  @app.register Sinatra::Synchrony
end
def app; @app end

describe 'A mock app' do
  include Rack::Test::Methods
  it 'successfully completes a sleep call' do
    mock_app {
      get '/?' do
        EM::Synchrony.sleep(0.0001)
        'ok'
      end
    }
    get '/'
    expect { last_response.ok? }
    expect { last_response.body == 'ok' }
  end
end