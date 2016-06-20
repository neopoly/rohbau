require 'spec_helper'
require 'rohbau/failure'

describe Rohbau::Failure do
  let(:cls) { Rohbau::Failure.required(:foo) }
  let(:instance) { cls.new(:foo => 'bar') }

  it 'inherits from Bound' do
    assert_includes cls.ancestors, Bound::StaticBoundClass
  end

  it 'is a failure' do
    assert_equal true, instance.failure?
  end

  it 'is no success' do
    assert_equal false, instance.success?
  end

  it 'it does not polute Class' do
    refute_includes Class.instance_methods, :failure?
  end
end
