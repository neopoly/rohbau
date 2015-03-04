require 'rohbau/service_factory'

module UserService
  class ServiceFactory < Rohbau::ServiceFactory
    register :user_service do
      UserService
    end
  end
end
