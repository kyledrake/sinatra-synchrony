Gem::Specification.new do |s|
  s.name = 'sinatra-synchrony'
  s.version = '0.1.0'
  s.authors = ['Kyle Drake']
  s.email = ['kyledrake@gmail.com']
  s.homepage = 'https://github.com/kyledrake/sinatra-synchrony'
  s.summary = 'Bootstraps Sinatra with EM-Synchrony code, make TCPSocket EM-aware, provides support for tests'
  s.description = 'Bootstraps in code required to take advantage of EventMachine/EM-Synchrony\'s concurrency enhancements for slow IO. Patches TCPSocket, which makes anything based on it EM-aware (including RestClient). Includes patch for tests. Requires ruby 1.9.'

  s.files = Dir['{lib/sinatra,lib/rack,spec}/**/*'] + Dir['[A-Z]*']
  s.require_path = 'lib'

  s.rubyforge_project = s.name
  s.required_rubygems_version =         '>= 1.3.4'
  s.add_dependency 'sinatra',           '>= 1.0'
  s.add_dependency 'rack-fiber_pool',   '= 0.9.1'
  s.add_dependency 'em-http-request',   '= 0.3.0'
  s.add_dependency 'em-synchrony',      '= 0.2.0'
  s.add_dependency 'em-resolv-replace', '= 1.1.1'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rack-test', '= 0.5.7'
  s.add_development_dependency 'wrong',     '= 0.5.0'
  s.add_development_dependency 'minitest'
end
