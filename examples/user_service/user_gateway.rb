require 'user_service/event_tube'
require 'user_entity'
require 'rohbau/default_memory_gateway'

module UserService
  class UserGateway < Rohbau::DefaultMemoryGateway
    def create(user_data)
      user = User.new(user_data)
      add(user)
      EventTube.publish :user_registered, UserRegisteredEvent.new(user)
    end

    class UserRegisteredEvent < Struct.new(:user)
    end
  end
end
