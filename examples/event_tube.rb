require 'user_service/event_tube'
require 'email_service/email_service'

UserRegister::EventTube.subscribe :user_registered do |event|
  EmailService.send_user_registration_email_to event.user # => 'Send out email to Bob'
end

UserRegister.create_user({:nickname => 'Bob'})
