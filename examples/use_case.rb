require 'user_service/runtime'
require 'user_service/request'
require 'user_service/create_user_use_case'

# Boot up user service
UserService::RuntimeLoader.new

request = UserService::Request.new

UserService::CreateUser.new(request, {:nickname => 'Bob'}).call # => 'Created user Bob'
