require 'simplecov'
require 'simplecov-console'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::Console,
]

SimpleCov.start :rails do
  add_filter 'bundle'
  SimpleCov.minimum_coverage 100
end
