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
        remove_instance_variable :@instance if defined? @instance
      end

      attr_accessor :registrar

      def registered(registrar)
        self.registrar = registrar
      end

      def new(*args)
        super(*args)
        self
      end
    end

    def initialize(runtime)
      return if singleton_assigned?
      build_singleton(runtime)
    end

    private

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

    def build_singleton(runtime)
      initialize_with_immediate_callback runtime do |instance|
        assign_to_singleton(instance)
      end
    end

    def singleton_variable
      :@instance
    end
  end
end
