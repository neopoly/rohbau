module Rohbau
  class ServiceFactory

    def initialize(runtime)
      raise "No Runtime instanciated" unless runtime
      @runtime = runtime
    end

    def self.register(service_name, &constructor)
      self.send :define_method, service_name do
        cache service_name do
          instance_eval(&constructor)
        end
      end
    end

    protected

    def cache(name, &block)
      @cache ||= {}
      @cache[name] ||= block.call
    end

    def runtime
      @runtime
    end

  end
end
