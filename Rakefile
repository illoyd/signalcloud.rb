require "bundler/gem_tasks"
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new('spec')
task :default => :spec
task :test => :spec

Dir.glob('tasks/*.rake').each { |r| import r }

