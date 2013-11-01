require 'rohbau/registry'

module Rohbau
  class ServiceFactory
    include Rohbau::Registry

    def initialize(runtime)
      raise "No Runtime instanciated" unless runtime
      @runtime = runtime
    end

    protected

    def runtime
      @runtime
    end

  end
end
