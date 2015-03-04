require 'rohbau/runtime'
require 'rohbau/runtime_loader'
require 'rohbau/service_factory'
require 'rohbau/request'
require 'user_service/create_user_use_case'

module UserService
  def self.create(user_data)
    print "Created user #{user_data[:nickname]}"
  end
end

module UserService
  class RuntimeLoader < Rohbau::RuntimeLoader
    def initialize
      super(Runtime)
    end
  end

  class Runtime < Rohbau::Runtime
  end
end

module UserService
  class ServiceFactory < Rohbau::ServiceFactory
    register :user_service do
      UserService
    end
  end

  class Request < Rohbau::Request
    def initialize(runtime = RuntimeLoader.instance)
      super(runtime)
    end

    protected

    def build_service_factory
      ServiceFactory.new(@runtime)
    end
  end
end
