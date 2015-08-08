require 'retryable/version'
require 'retryable/exponential_backoff'

# A module to allow the retry of code blocks
#
# Here are some example usages
#
# Usage:
#    class MyClass
#       include Retryable
#       def my_method
#         retryable(tries: 5, sleep: 3, on: MyError) do |attempt, excption|
#           # something that may fail
#         end
#       end
#     end
#
# args:
#   +tries+          : the number of times you want to try it
#   +sleep+          : the sleep time between each retry, this can be a proc
#   +on+             : a list of exceptions you want to be able to retry on
#   +retry_callback+ : a proc that gets executed on every retry (useful for logging)
#                         proc { |attempt, exception| #... }
#                         -> (attempt, excption) { |attempt, exception| #... }
#
module Retryable
  class << self
    def enabled?
      enable if @enabled.nil?
      @enabled
    end

    def disabled?
      disable if @enabled.nil?
      !@enabled
    end

    def enable
      @enabled = true
    end

    def disable
      @enabled = false
    end
  end

  def retryable(tries: 1, on: StandardError, sleep: 0, exception_callback: proc {}, &_block) # rubocop:disable Metrics/MethodLength
    attempt = 1
    exception = nil

    begin
      yield attempt, exception
    rescue *on => e
      if attempt == tries || Retryable.disabled?
        raise
      else
        exception = e
        exception_callback.call(attempt, exception)
        sleep_time = (sleep.respond_to? :call) ? sleep.call(attempt) : sleep
        Kernel.sleep sleep_time
        attempt += 1
        retry
      end
    end
  end

  def with_exponential_backoff(opts, &_block)
    opts[:sleep] = ExponentialBackoff.new
    retryable(opts) do |attempt, exception|
      yield attempt, exception
    end
  end
end
