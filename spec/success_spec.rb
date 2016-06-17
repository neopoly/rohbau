require 'spec_helper'
require 'rohbau/success'

describe Rohbau::Success do
  let(:subject) { Rohbau::Success.new }

  it 'inherits from Bound' do
    assert_includes subject.ancestors, Bound::StaticBoundClass
  end

  it 'is a success' do
    assert_equal true, subject.success?
  end

  it 'is no failure' do
    assert_equal false, subject.failure?
  end

  it 'it does not polute Class' do
    refute_includes Class.instance_methods, :success?
  end
end
