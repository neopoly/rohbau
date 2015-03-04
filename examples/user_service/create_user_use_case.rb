require 'rohbau/use_case'

module UserService
  def self.create(user_data)
    print "Created user #{user_data[:nickname]}"
  end
end

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
