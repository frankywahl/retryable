# Retryable

A gem to quickly make retrying a block accessible when raising an error.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'retryable', git: 'git@github.com:frankywahl/retryable.git'
```

And then execute:

    $ bundle

## Usage

In any class, use just include the module to access the retryable stuff


Here is a complete example
```ruby
class Foo
  class MyError < StandardError; end
  class MyErrorBis < StandardError; end

  include Retryable
  def my_method
    callback = ->(attempt, exception) do
      puts "Attempt #{attempt} raised #{exception.class} error"
    end
    retryable(tries: 5, on: [MyError, MyErrorBis], sleep: 3, exception_callback: callback) do |attempt, exception|
      raise MyError if attempt < 5
    end
  end
end

Foo.new.my_method
```

Fun fact:
`sleep` can take an `Integer` amount of seconds, or can also take a `Proc` that gets called with the attempt number. This allows for custom algorithm. Example

```ruby
exponential_backoff = -> (attempt) { 10 ** attempt }
# this will wait for 10, 100, 1_000, ... seconds
```

## Development

Download this repository. Then

```bash
bundle install
```

And start developing.

Tests are at

```bash
bundle exec rake
```


## Contributing

1. Fork it ( https://github.com/[my-github-username]/retryable/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Thanks
The code for this was inspired by [nfedyashev/retryable](https://github.com/nfedyashev/retryable) and sometimes used as a reference point.
