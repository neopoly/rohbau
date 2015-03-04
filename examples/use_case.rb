require 'user_service'

# Boot up user service
UserService::RuntimeLoader.new

request = UserService::Request.new

UserService::CreateUser.new(request, {:nickname => 'Bob'}).call # => 'Created user Bob'
