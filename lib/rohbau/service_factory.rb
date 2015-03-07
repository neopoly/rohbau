require 'rohbau/registry'

module Rohbau
  class ServiceFactory
    include Rohbau::Registry

    def initialize(runtime)
      raise "No Runtime instantiated" unless runtime
      @runtime = runtime
    end

    def self.external_dependencies_complied?
      missing_dependencies.empty?
    end

    def self.missing_dependencies
      external_dependencies.reject do |dependency|
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
