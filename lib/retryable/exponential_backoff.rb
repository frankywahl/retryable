module Retryable
  class ExponentialBackoff
    def call(integer)
      2**integer
    end
  end
end
