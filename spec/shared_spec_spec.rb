require 'spec_helper'
require 'rohbau/shared_spec'

describe Rohbau::SharedSpec do
  before do
    Rohbau::SharedSpec::SpecIndex.reset
  end

  let(:shared_spec_class) { Class.new(Rohbau::SharedSpec) }

  it 'provides access the stored blocks' do
    blk = -> {}

    shared_spec_class.for :test1, &blk

    assert_equal Proc.new(&blk), shared_spec_class.get(:test1)
  end

  describe 'index' do
    let(:second_shared_spec_class) { Class.new(Rohbau::SharedSpec) }
    let(:index) { Rohbau::SharedSpec::SpecIndex }

    it 'collects all inherited specs' do
      assert_equal [
        shared_spec_class,
        second_shared_spec_class
      ], index.all
    end

    it 'looks up spec on all registered children' do
      blk1 = -> {}
      blk2 = -> {}

      shared_spec_class.for :test1, &blk1
      second_shared_spec_class.for :test2, &blk2

      assert_equal Proc.new(&blk1), index.get(:test1)
      assert_equal Proc.new(&blk2), index.get(:test2)
      assert_equal nil,             index.get(:something)
    end
  end
end
