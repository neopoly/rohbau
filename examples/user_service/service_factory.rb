require 'rohbau/service_factory'
require 'user_service/user_gateway'

module UserService
  class ServiceFactory < Rohbau::ServiceFactory
    register :user_service do
      UserGateway.new
    end
  end
end
