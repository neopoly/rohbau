require 'rohbau/use_case'

module UserService
  class CreateUser < Rohbau::UseCase
    def initialize(request, user_data)
      super(request)
      @user_data = user_data
    end

    def call
      service(:user_service).create(@user_data)
    end
  end
end
