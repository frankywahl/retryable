require 'simplecov'
require 'simplecov-console'
require 'codeclimate-test-reporter'

CodeClimate::TestReporter.start

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::Console,
  CodeClimate::TestReporter::Formatter
]

SimpleCov.start :rails do
  add_filter 'bundle'
  SimpleCov.minimum_coverage 100
end
