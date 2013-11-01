require 'spec_helper'
require 'rohbau/runtime_loader'

describe Rohbau::RuntimeLoader do

  let(:my_runtime_loader) do
    Class.new(Rohbau::RuntimeLoader)
  end

  let(:example_class) do
    Class.new
  end

  it 'starts up a given class' do
    my_runtime_loader.new(example_class)

    assert_kind_of example_class, my_runtime_loader.instance
  end

  it 'fails if it was already instanciated' do
    my_runtime_loader.new(example_class)

    raised = assert_raises RuntimeError do
      my_runtime_loader.new(example_class)
    end

    assert_match(/already/, raised.message)
  end

end
