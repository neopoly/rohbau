module Rohbau
  class Request

    def initialize(runtime)
      raise "No Runtime instanciated" unless runtime
      @runtime = runtime
    end

    def services
      @service_factory ||= build_service_factory
    end

    protected

    def build_service_factory
      raise NotImplementedError, "Please provide #{self.class}#build_service_factory"
    end

    def runtime
      @runtime
    end

  end
end
