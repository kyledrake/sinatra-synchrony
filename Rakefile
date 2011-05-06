require 'bundler'

Bundler.setup
Bundler::GemHelper.install_tasks

require "rake/testtask"

desc "Run all tests"
Rake::TestTask.new do |t|
  t.libs << "spec"
  t.test_files = FileList['spec/*_spec.rb']
  t.verbose = true
end

task :default => :test