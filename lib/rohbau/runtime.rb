require 'pathname'

module Rohbau
  class Runtime
    class << self
      attr_reader :instance

      def start
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
      # noop
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

  end
end
