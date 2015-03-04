require 'user_service/event_tube'

module UserService
  class UserGateway
    def create(user_data)
      user = user_data
      EventTube.publish :user_registered, UserRegisteredEvent.new(user)
    end

    class UserRegisteredEvent < Struct.new(:user)
    end
  end
end
