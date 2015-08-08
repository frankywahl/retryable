$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'retryable'

begin
  require 'pry'
rescue LoadError
  puts 'No Pry :('
end

RSpec.configure do
  def retryable_test(*opts, &block)
    Class.new do
      include Retryable

      def raising_method(*opts)
        retryable(*opts) do |*args|
          yield(*args)
        end
      end
    end.new.raising_method(*opts, &block)
  end

  def retryable_backoff(*opts, &block)
    Class.new do
      include Retryable

      def raising_method(*opts)
        with_exponential_backoff(*opts) do |*args|
          yield(*args)
        end
      end
    end.new.raising_method(*opts, &block)
  end
end
