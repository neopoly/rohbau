require 'rohbau/runtime'
require 'rohbau/runtime_loader'

module UserService
  class RuntimeLoader < Rohbau::RuntimeLoader
    def initialize
      super(Runtime)
    end
  end

  class Runtime < Rohbau::Runtime
  end
end
