module Rohbau
  module Application
    class RuntimeWrapper
      def self.wrap(&constructor)
        wrapper = Class.new do
          def self.set_constructor(constructor)
            @constructor = constructor
            self
          end

          def self.new(*ignored_args)
            @constructor.call
          end
        end

        wrapper.set_constructor(constructor)
      end
    end

    def set_application_runtime(runtime_class)
      @runtime_class = runtime_class
    end

    def register_domain(name, namespace)
      dummy = RuntimeWrapper.wrap do |cls|
        namespace::Runtime.start
      end

      @runtime_class.register name, dummy

      domains << namespace
    end

    def domains
      @domains ||= []
    end

    def domain_requests
      domains.map { |d| d.const_get :Request }
    end

    def use_case_domains
      domains.select do |domain|
        domain.const_defined?('UseCases')
      end
    end

    def use_cases(use_case_domain = :all)
      if use_case_domain == :all
        domains = use_case_domains
      else
        domains = [use_case_domain]
      end

      domains.inject([]) do |use_cases, domain|
        if domain.const_defined?('UseCases')
          use_case_namespace = domain.const_get('UseCases')
          use_case_namespace.constants.each do |use_case_class_name|
            use_cases << use_case_namespace::const_get(use_case_class_name)
          end
        end

        use_cases
      end
    end
  end
end
