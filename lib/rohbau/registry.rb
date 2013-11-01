module Rohbau
  module Registry
    def self.included(cls)
      cls.send :extend, ExternalInterface
      cls.send :include, Implementation
    end

    module Implementation
      def cache(name, &block)
        @cache ||= {}
        @cache[name] ||= block.call
      end
    end

    module ExternalInterface
      def register(service_name, &constructor)
        self.send :define_method, service_name do
          cache service_name do
            instance_eval(&constructor)
          end
        end
      end
    end
  end
end
