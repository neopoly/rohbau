require 'rohbau/runtime'
require 'rohbau/runtime_loader'

module MyApplication
  class RuntimeLoader < Rohbau::RuntimeLoader
    def initialize
      super(Runtime)
    end
  end

  class Runtime < Rohbau::Runtime
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

# Register user service on my application runtime
MyApplication::Runtime.register :user_service, UserService::RuntimeLoader
MyApplication::Runtime.plugins[:user_service] # => {:user_service=>UserService::RuntimeLoader}

# Runtimes are not initialized yet
MyApplication::RuntimeLoader.instance # => nil
MyApplication::Runtime.plugins[:user_service].instance # => nil

# Boot my application runtime
MyApplication::RuntimeLoader.running? # => false
MyApplication::RuntimeLoader.new
MyApplication::RuntimeLoader.running? # => true

# Runtimes are initialized
MyApplication::RuntimeLoader.instance # => #<MyApplication::Runtime:0x00000000f5b8d8 @user_service=UserService::RuntimeLoader>
MyApplication::Runtime.plugins[:user_service].instance # => #<UserService::Runtime:0x00000000b1ecc0>

# Runtimes are singletons
MyApplication::RuntimeLoader.instance === MyApplication::RuntimeLoader.instance
MyApplication::Runtime.plugins[:user_service].instance === MyApplication::Runtime.plugins[:user_service].instance

# Terminate my application runtime
MyApplication::RuntimeLoader.terminate
MyApplication::RuntimeLoader.running? # => false
