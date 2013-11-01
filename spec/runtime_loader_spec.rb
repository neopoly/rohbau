require 'spec_helper'
require 'rohbau/runtime_loader'

describe Rohbau::RuntimeLoader do
  ExampleClass = Class.new

  let(:my_runtime_loader) do
    Class.new(Rohbau::RuntimeLoader)
  end

  before do
    my_runtime_loader.new(ExampleClass)
  end

  it 'starts up a given class' do
    assert_kind_of ExampleClass, my_runtime_loader.instance
  end

  it 'fails if it was already instanciated' do
    raised = assert_raises RuntimeError do
      my_runtime_loader.new(ExampleClass)
    end

    assert_match(/already/, raised.message)
  end

end
