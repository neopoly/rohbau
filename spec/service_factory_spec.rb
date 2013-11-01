require 'spec_helper'
require 'rohbau/service_factory'

describe Rohbau::ServiceFactory do

  let(:factory_class) do
    Class.new(Rohbau::ServiceFactory)
  end

  let(:factory) do
    factory_class.new(Object.new)
  end

  it 'needs a runtime instance to get instanciated' do
    raised = assert_raises RuntimeError do
      factory_class.new(nil)
    end

    assert_match(/Runtime/, raised.message)
  end

  describe 'service registration' do
    before do
      factory_class.register :test_service do
        Struct.new(:a).new(22)
      end
    end

    it 'allows access via a named method' do
      assert_kind_of Struct, factory.test_service
      assert_equal 22, factory.test_service.a
    end

    it 'caches service instances' do
      identity_of_first_call = factory.test_service.object_id
      identity_of_second_call = factory.test_service.object_id
      assert_equal identity_of_first_call, identity_of_second_call
    end
  end

end
