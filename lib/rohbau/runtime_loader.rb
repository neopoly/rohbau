module Rohbau
  class RuntimeLoader

    class << self
      def instance
        @instance
      end

      def running?
        !!instance
      end

      def terminate
        instance.terminate if instance.respond_to? :terminate
        remove_instance_variable :@instance
      end

    end

    def initialize(runtime)
      ensure_singleton_is_unassigned!
      initialize_with_immediate_callback runtime do |instance|
        assign_to_singleton(instance)
      end
    end


    private
    def ensure_singleton_is_unassigned!
      if singleton_assigned?
        msg = "#{self.class}: Runtime already initialized: #{singleton.inspect}"
        raise RuntimeError, msg
      end
    end

    def singleton_assigned?
      self.class.instance_variable_defined? singleton_variable
    end

    def singleton
      self.class.instance_variable_get singleton_variable
    end

    def initialize_with_immediate_callback(cls, &callback)
      cls.send :define_method, :initialize do |*args|
        callback.call(self)
        super(*args)
      end

      cls.new
    end

    def assign_to_singleton(instance)
      self.class.instance_variable_set singleton_variable, instance
    end

    def singleton_variable
      :@instance
    end
  end
end
