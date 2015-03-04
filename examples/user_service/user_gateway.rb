require 'user_service/event_tube'
require 'user_entity'

module UserService
  class UserGateway
    def create(user_data)
      user = User.new(user_data)
      EventTube.publish :user_registered, UserRegisteredEvent.new(user)
    end

    class UserRegisteredEvent < Struct.new(:user)
    end
  end
end
