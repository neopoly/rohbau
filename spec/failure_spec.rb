require 'spec_helper'
require 'rohbau/failure'

describe Rohbau::Failure do
  let(:subject) { Rohbau::Failure.new }

  it 'inherits from Bound' do
    assert_includes subject.ancestors, Bound::StaticBoundClass
  end

  it 'is a failure' do
    assert_equal true, subject.failure?
  end

  it 'is no success' do
    assert_equal false, subject.success?
  end

  it 'it does not polute Class' do
    refute_includes Class.instance_methods, :failure?
  end
end
