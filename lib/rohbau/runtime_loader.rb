module Rohbau
  class RuntimeLoader

    class << self
      attr_reader :instance
    end

    def initialize(runtime)
      if self.class.instance_variable_defined? :@instance
        instance = self.class.instance_variable_get :@instance
        msg = "Runtime already initialized: #{instance.inspect}"
        raise RuntimeError, msg
      end
      self.class.instance_variable_set :@instance, runtime.new
    end
  end
end
