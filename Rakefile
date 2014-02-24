require "rubygems"
require "bundler/setup"

require 'appraisal'

require "bundler/gem_tasks"
require "rspec/core"
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

desc 'Default: run tests.'
task :default => ['appraisal:install', :all]

desc "Run tests for all rails versions"
task :all do
  exec('rake appraisal spec')
end