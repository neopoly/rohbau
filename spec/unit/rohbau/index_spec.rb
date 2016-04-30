require 'spec_helper'
require 'rohbau/index'

describe Rohbau::Index do
  let(:index) { Rohbau::Index.new }

  describe 'initialize' do
    it 'has size 0' do
      assert_equal 0, index.size
    end

    it 'does not contain any entities' do
      assert_equal [], index.all
      assert_equal [], index.each.to_a
    end
  end
end
