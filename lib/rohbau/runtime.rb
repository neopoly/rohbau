require 'pathname'
require 'thread_safe'

module Rohbau
  class Runtime
    def self.register(name, plugin_class)
      attr_reader name
      plugins[name] = plugin_class
      plugin_class.registered(self) if plugin_class.respond_to?(:registered)
    end

    def self.unregister(name)
      remove_method name
      plugins.delete name
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
      after_termination
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

    def after_termination
    end

    def initialize_plugins
      self.class.plugins.each do |name, plugin_class|
        instance_variable_set :"@#{name}", plugin_class.new
      end
    end

    def notify_plugins(message, *args)
      self.class.plugins.each do |name, _|
        plugin = public_send(name)
        if plugin.instance.respond_to? message
          plugin.instance.public_send(message, *args)
        end
      end
    end

    def terminate_plugins
      self.class.plugins.each do |name, _|
        plugin = public_send(name)
        plugin.terminate if plugin.respond_to? :terminate
      end
    end

    def handle_transaction(&block)
      if transaction_handling_plugin
        transaction_handling_plugin.transaction_handler(&block)
      else
        block.call
      end
    end

    def transaction_handling_plugin
      return @handling_plugin if defined? @handling_plugin

      plugin = self.class.plugins.detect do |_, runtime_loader|
        runtime_loader.instance.respond_to? :transaction_handler
      end
      if plugin
        @handling_plugin = plugin[1].instance
      else
        @handling_plugin = nil
      end
    end
  end
end
