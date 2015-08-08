require 'bundler/gem_tasks'

require 'rubygems/tasks'
Gem::Tasks.new do |tasks|
  tasks.console.command = 'pry'
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new

require 'rubocop/rake_task'
RuboCop::RakeTask.new

task test: :spec
task default: [:spec, :rubocop]
