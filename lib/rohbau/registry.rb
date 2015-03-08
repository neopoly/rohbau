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
        implementations[service_name] << constructor

        define_method service_name do
          cache service_name do
            instance_eval(&self.class.implementations[service_name].last)
          end
        end
      end

      def unregister(service_name)
        implementations[service_name].pop

        if implementations[service_name].empty?
          remove_method service_name
        end
      end

      def registrations
        implementations.keys
      end

      def implementations
        @implementations ||= Hash.new { |hash, key| hash[key] = [] }
      end
    end
  end
end
