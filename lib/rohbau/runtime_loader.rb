module Rohbau
  class RuntimeLoader

    class << self
      attr_reader :instance
    end

    def initialize(runtime)
      ensure_singleton_is_unassigned!
      assign_to_singleton(runtime.new)
    end

    private
    def ensure_singleton_is_unassigned!
      if singleton_assigned?
        msg = "Runtime already initialized: #{singleton.inspect}"
        raise RuntimeError, msg
      end
    end

    def singleton_assigned?
      self.class.instance_variable_defined? singleton_variable
    end

    def singleton
      self.class.instance_variable_get singleton_variable
    end

    def assign_to_singleton(instance)
      self.class.instance_variable_set singleton_variable, instance
    end

    def singleton_variable
      :@instance
    end
  end
end