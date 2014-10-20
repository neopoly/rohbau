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

  describe 'external dependency compliance' do
    it 'is reached if there are none' do
      assert_predicate factory_class, :external_dependencies_complied?
    end

    describe 'with external dependencies' do
      before do
        factory_class.external_dependencies :service1, :service2
      end

      it 'is not reached without any registered external service' do
        refute_predicate factory_class, :external_dependencies_complied?
      end

      it 'is not reached with partially registers services' do
        factory_class.register(:service1) {  }
        refute_predicate factory_class, :external_dependencies_complied?
      end

      it 'is reached if all required dependencies are registered' do
        factory_class.register(:service1) {  }
        factory_class.register(:service2) {  }
        assert_predicate factory_class, :external_dependencies_complied?
      end
    end
  end

  describe 'service registration' do
    describe "with one service registered" do
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

      it "can unregister services" do
        factory_class.unregister(:test_service)

        assert_raises(NoMethodError) {factory.test_service}
      end

      describe "with more than one service registered" do
        before do
          factory_class.register :test_service do
            Struct.new(:a).new(23)
          end
        end

        it "uses the most recently defined service" do
          assert_kind_of Struct, factory.test_service
          refute_equal 22, factory.test_service.a
          assert_equal 23, factory.test_service.a
        end

        it "uses the default implementation when unregistered" do
          factory_class.unregister(:test_service)

          assert_kind_of Struct, factory.test_service
          assert_equal 22, factory.test_service.a
        end

        it "removes the service if unregistered twice" do
          factory_class.unregister(:test_service)
          factory_class.unregister(:test_service)

          assert_raises(NoMethodError) {factory.test_service}
        end
      end
    end

  end

end
