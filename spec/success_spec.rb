require 'spec_helper'
require 'rohbau/success'

describe Rohbau::Success do
  let(:cls) { Rohbau::Success.required(:foo) }
  let(:instance) { cls.new(:foo => 'bar') }

  it 'inherits from Bound' do
    assert_includes cls.ancestors, Bound::StaticBoundClass
  end

  it 'is a success' do
    assert_equal true, instance.success?
  end

  it 'is no failure' do
    assert_equal false, instance.failure?
  end

  it 'it does not polute Class' do
    refute_includes Class.instance_methods, :success?
  end
end
