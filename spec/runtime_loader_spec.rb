require 'minitest/mock'

require 'spec_helper'
require 'rohbau/runtime_loader'

describe Rohbau::RuntimeLoader do
  ExampleClass = Class.new

  let(:my_runtime_loader) do
    Class.new(Rohbau::RuntimeLoader)
  end

  before do
    @initializer_result = my_runtime_loader.new(ExampleClass)
  end

  it 'starts up a given class' do
    assert_kind_of ExampleClass, my_runtime_loader.instance
  end

  it 'has a running predicate after init' do
    assert_predicate my_runtime_loader, :running?
  end

  it 'returns the loader class on new' do
    assert_equal my_runtime_loader, @initializer_result
  end

  describe 'termination' do
    it 'has no running predicate afterwards' do
      my_runtime_loader.terminate
      refute_predicate my_runtime_loader, :running?
    end

    it 'sets instance to nil' do
      my_runtime_loader.terminate
      assert_equal nil, my_runtime_loader.instance
    end

    it 'calls terminate on instance, if it responds to it' do
      mocked_instance = inject_mocked_instance_into_my_runtime_loader
      mocked_instance.expect(:terminate, nil)

      my_runtime_loader.terminate

      assert mocked_instance.verify
    end

    it 'is initializeable after termination' do
      my_runtime_loader.terminate
      my_runtime_loader.new(ExampleClass)
    end
  end

  it 'fails if it was already instanciated' do
    raised = assert_raises RuntimeError do
      my_runtime_loader.new(ExampleClass)
    end

    assert_match(/already/, raised.message)
  end


  def inject_mocked_instance_into_my_runtime_loader
    instance = MiniTest::Mock.new

    def my_runtime_loader.instance
      @__mocked_instance
    end
    my_runtime_loader.instance_variable_set :@__mocked_instance, instance
  end
end
