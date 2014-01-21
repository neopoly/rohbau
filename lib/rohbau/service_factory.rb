require 'rohbau/registry'

module Rohbau
  class ServiceFactory
    include Rohbau::Registry

    def initialize(runtime)
      raise "No Runtime instanciated" unless runtime
      @runtime = runtime
    end

    def self.external_dependencies_complied?
        external_dependencies.all? do |dependency|
          registrations.include? dependency
        end
    end

    def self.external_dependencies(*dependencies)
      if dependencies.any?
        @external_dependencies = dependencies
      else
        @external_dependencies ||= []
      end
    end

    protected

    def runtime
      @runtime
    end

  end
end
