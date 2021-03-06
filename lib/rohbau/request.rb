module Rohbau
  class Request
    def initialize(runtime)
      raise "No Runtime instantiated (#{self.inspect})" unless runtime
      @runtime = runtime
    end

    def services
      @service_factory ||= build_service_factory
    end

    protected

    def build_service_factory
      raise NotImplementedError
    end

    def runtime
      @runtime
    end
  end
end
