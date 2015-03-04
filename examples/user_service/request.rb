require 'rohbau/request'
require 'user_service/service_factory'

module UserService
  class Request < Rohbau::Request
    def initialize(runtime = RuntimeLoader.instance)
      super(runtime)
    end

    protected

    def build_service_factory
      ServiceFactory.new(@runtime)
    end
  end
end
