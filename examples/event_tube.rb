require 'user_service/event_tube'
require 'user_service/user_gateway'
require 'email_service/email_service'

UserService::EventTube.subscribe :user_registered do |event|
  EmailService.send_user_registration_email_to event.user # => 'Send out email to Bob'
end

UserService::UserGateway.new.create(:nickname => 'Bob')
