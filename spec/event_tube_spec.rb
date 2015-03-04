require 'spec_helper'
require 'rohbau/event_tube'

describe Rohbau::EventTube do
  let(:tube)        { Class.new(Rohbau::EventTube)}
  let(:event_class) { Struct.new(:arg1) }
  let(:event)       { event_class.new(22) }

  describe 'without subscribers' do
    it 'can publish' do
      tube.publish :my_event, event
    end
  end

  describe 'with subscriber' do
    before do
      @calls = []
      tube.subscribe :my_event do |event|
        @calls << event
      end
    end

    it 'can publish' do
      tube.publish :my_event, event
      assert_equal [event], @calls
    end
  end

  describe 'with multiple subscribers' do
    before do
      @calls = []

      tube.subscribe :my_event do |event|
        @calls << event
      end

      tube.subscribe :my_event do |event|
        @calls << event
      end
    end

    it 'processes them all on publish' do
      tube.publish :my_event, event
      assert_equal [event,event], @calls
    end
  end

  describe 'reset' do
    before do
      @calls = []
      tube.subscribe :my_event do |event|
        @calls << event
      end
    end

    it 'does nothin on publish' do
      tube.reset
      tube.publish :my_event, event
      assert_equal [], @calls
    end
  end
end
