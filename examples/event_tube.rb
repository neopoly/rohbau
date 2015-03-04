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

class EmailService
  def self.send_user_registration_email_to(user)
    print "Send out email to #{user[:nickname]}"
  end
end

UserRegister::EventTube.subscribe :user_registered do |event|
  EmailService.send_user_registration_email_to event.user # => 'Send out email to Bob'
end

UserRegister.create_user({:nickname => 'Bob'})
