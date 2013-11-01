require 'pathname'

module Rohbau
  class Runtime
    class << self
      attr_reader :instance

      def start
        raise "Don't use Runtime.start, you should use a RuntimeLoader"
        set_instance = proc do |instance|
          @instance = instance
        end

        self.send :define_method, :initialize do |*args|
          set_instance.call(self)
          super(*args)
        end

        new
      end

      def running?
        !!@instance
      end

      def terminate
        @instance.terminate
        @instance = nil
      end
    end

    def self.register(name, plugin_class)
      attr_reader name
      plugins[name] = plugin_class
    end

    def self.plugins
      @plugins ||= {}
    end

    def initialize
      on_boot
      initialize_plugins
    end

    def terminate
      terminate_plugins
    end

    def root
      Pathname.new(Dir.pwd)
    end

    protected

    def on_boot
      # noop
    end

    def initialize_plugins
      self.class.plugins.each do |name, plugin_class|
        instance_variable_set :"@#{name}", plugin_class.new
      end
    end

    def terminate_plugins
      self.class.plugins.each do |name, _|
        plugin = public_send(name)
        plugin.terminate if plugin.respond_to? :terminate
      end
    end

  end
end
