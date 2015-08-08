require 'spec_helper'

RSpec.describe 'Retryable' do
  let(:counter_double) { double(foo: :foo) }
  before :each do
    class MyError < StandardError; end
    allow(Kernel).to receive(:sleep).and_return(nil)
    Retryable.enable
  end

  describe '#enabled?, #disabled?' do
    subject do
      retryable_test(tries: 2, on: MyError) do |attempt, _exception|
        raise MyError if attempt < 2
      end
    end

    context 'when active' do
      before :each do
        Retryable.enable
      end

      it 'responds correctly' do
        expect(Retryable.disabled?).to be false
        expect(Retryable.enabled?).to be true
      end

      it 'runs the block multiple times' do
        expect { subject }.not_to raise_error
      end
    end

    context 'when inactive' do
      before :each do
        Retryable.disable
      end

      it 'responds correctly' do
        expect(Retryable.disabled?).to be true
        expect(Retryable.enabled?).to be false
      end

      it 'fails the first time' do
        expect { subject }.to raise_error MyError
      end
    end
  end

  describe '#retryable' do
    it 'raises the error' do
      expect do
        retryable_test(on: MyError) do |_attempt, _exception|
          raise MyError
        end
      end.to raise_error MyError
    end

    it 'retries the code block' do
      expect(counter_double).to receive(:foo).exactly(2).times
      retryable_test(tries: 2, on: MyError) do |attempt, _exception|
        counter_double.foo
        raise MyError if attempt < 2
      end
    end

    context 'sleep time' do
      it 'can take a proc' do
        [1, 2, 3, 4].each { |i| expect(Kernel).to receive(:sleep).with(i).ordered.and_return(nil) }
        retryable_test(tries: 5, sleep: ->(n) { n }) do |attempt, _exception|
          raise StandardError if attempt < 5
        end
      end

      it 'can take a integer' do
        expect(Kernel).to receive(:sleep).with(3).exactly(3).times.and_return(nil)
        retryable_test(tries: 4, sleep: 3) do |attempt, _exception|
          raise StandardError if attempt < 4
        end
      end
    end

    it 'does not retry when other exception is given' do
      expect(counter_double).to receive(:foo).once
      expect do
        retryable_test(tries: 5, on: RuntimeError) do |_attempt, _exception|
          counter_double.foo
          raise StandardError
        end
      end.to raise_error StandardError
    end

    it 'passes the exception object when retrying' do
      retryable_test(tries: 5, on: MyError) do |attempt, exception|
        if attempt == 1
          expect(exception).to be_nil
        else
          expect(exception.class).to eq MyError unless attempt == 1
        end
        raise MyError if attempt < 5
      end
    end

    it 'can take an array of errors' do
      expect(counter_double).to receive(:foo).exactly(2).times
      expect do
        retryable_test(tries: 5, on: [MyError, StandardError]) do |attempt, _exception|
          case attempt
          when 1
            counter_double.foo
            raise MyError
          when 2
            counter_double.foo
            raise StandardError
          end
        end
      end.not_to raise_error
    end

    context 'exception_callback' do
      it 'invokes the callback with the right error' do
        callback = ->(_attempt, exception) { expect(exception.class).to eql MyError }
        retryable_test(tries: 5, exception_callback: callback) do |attempt, _exception|
          raise MyError if attempt < 5
        end
      end

      it 'calls it with the right arguments' do
        callback = ->(_attempt, _exception) {}
        [
          [1, MyError],
          [2, ArgumentError]
        ].each { |arguments| expect(callback).to receive(:call).with(*arguments).ordered.and_call_original }
        retryable_test(tries: 5, exception_callback: callback) do |attempt, _exception|
          case attempt
          when 1
            raise MyError
          when 2
            raise ArgumentError
          end
        end
      end
    end
  end

  describe '#with_exponential_backoff' do
    it 'provides a default algorithm' do
      [2, 4, 8, 16].each { |i| expect(Kernel).to receive(:sleep).with(i).ordered.and_return(nil) }
      retryable_backoff(tries: 5) do |attempt, _exception|
        raise StandardError if attempt < 5
      end
    end
  end
end
