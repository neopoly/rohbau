require_relative 'runtime'
require_relative 'request_cache'

module Rohbau
  class Interface
    include RequestCache
    def initialize
      @calls = Hash.new { |h, k| h[k] = nil }
      @call_count = Hash.new { |h, k| h[k] = 0 }
      @stub_results = Hash.new { |h, k| h[k] = nil }
      @stub_type_for = Hash.new { |h, k| h[k] = nil }
    end

    def clear_stubs
      calls.clear
      call_count.clear
      stub_results.clear
      stub_type_for.clear
    end

    def clear_cached_requests
      RequestCache.clear
    end

    def calls
      @calls
    end

    def call_count
      @call_count
    end

    private

    def call_use_case(domain, use_case, args)
      call_count[use_case] += 1 unless args.key?(:stub_result)
      calls[use_case] = args
      domain = camel_case(domain)
      use_case = camel_case(use_case)
      caller = Caller.new domain

      overwrite_stub_result_for(use_case, args[:stub_result])
      overwrite_stub_type_for(use_case, args[:stub_type])

      caller.call use_case, args,
        :stub_result => stub_results[use_case],
        :stub_type => stub_type_for[use_case] || :Success
    end

    def overwrite_stub_result_for(use_case, stub_result)
      return if stub_result.nil?
      stub_results[use_case] = stub_result
    end

    def overwrite_stub_type_for(use_case, stub_type)
      return if stub_type.nil?
      stub_type_for[use_case] = stub_type
    end

    def stub_results
      @stub_results
    end

    def stub_type_for
      @stub_type_for
    end

    def camel_case(sym)
      sym.to_s.split('_').each(&:capitalize!).join
    end

    def method_missing(domain, *args)
      use_case = args[0]
      input = args[1] || {}
      call_use_case(domain, use_case, input)
    rescue NameError => e
      msg = "You tried to call a use case from the #{domain} domain, " \
        "but the following error occured: #{e.inspect}"
      raise msg
    end

    class Caller
      def initialize(domain)
        @domain = domain
      end

      def call(use_case, args, options = {})
        type = options[:stub_type]
        stubbed_result = options[:stub_result]
        use_case = get_use_case_for(use_case, args)

        if stubbed_result
          stub_use_case(use_case, type, stubbed_result)
        else
          call_use_case(use_case, args)
        end
      end

      private

      def call_use_case(use_case, args)
        request = RequestCache.for[domain]
        input = get_input_for(use_case, args)

        use_case.new(request, input).call
      end

      def stub_use_case(use_case, type, result)
        use_case = Object.const_get "#{use_case}::#{type}"

        return use_case.new if result == true
        use_case.new(result)
      end

      def get_input_for(use_case, args)
        use_case = Object.const_get "#{use_case}::Input"
        use_case.new(args)
      end

      def get_use_case_for(use_case, args)
        Object.const_get "#{domain}::UseCases::#{use_case}"
      end

      def domain
        @domain
      end
    end
  end
end
