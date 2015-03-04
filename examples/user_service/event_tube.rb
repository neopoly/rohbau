require 'rohbau/event_tube'

module UserRegister
  class EventTube < Rohbau::EventTube
  end

  def self.create_user(user)
    EventTube.publish :user_registered, UserRegisteredEvent.new(user)
  end

  class UserRegisteredEvent < Struct.new(:user)
  end
end
