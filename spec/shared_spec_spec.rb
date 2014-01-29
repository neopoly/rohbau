require 'spec_helper'
require 'rohbau/shared_spec'

describe Rohbau::SharedSpec do

  before do
  end

  let(:shared_spec_class) { Class.new(Rohbau::SharedSpec) }

  it 'provides access the stored blocks' do
    blk = -> {}

    shared_spec_class.for :test1, &blk

    assert_equal_proc Proc.new(&blk), shared_spec_class.get(:test1)
  end

  private

  def assert_equal_proc(exp, act)
    assert_equal exp, act
  end
end
