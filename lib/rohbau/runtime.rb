require 'pathname'

module Rohbau
  class Runtime
    class << self
      attr_reader :instance

      def start
        @instance = new
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
      @@plugins ||= {}
    end

    def initialize
      initialize_plugins
      on_boot
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
        instance_variable_set :"@#{name}", plugin_class.new(self)
      end
    end

  end
end
