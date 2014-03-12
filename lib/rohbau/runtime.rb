require 'pathname'

module Rohbau
  class Runtime
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
      after_boot
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

    def after_boot
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
