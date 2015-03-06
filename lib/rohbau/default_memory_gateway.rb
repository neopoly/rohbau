require 'rohbau/index'

module Rohbau
  class DefaultMemoryGateway
    def initialize(memory = Index.new, services = {})
      @memory = memory
      @services = services
    end

    def memory
      @memory
    end

    def add(entity)
      @memory.add entity
    end

    def bulk_add(*entities)
      @memory.bulk_add(*entities)
    end

    def get(uid)
      @memory.get(uid)
    end

    def update(entity)
      @memory.update(entity)
    end

    def delete(uid)
      @memory.delete(uid)
    end

    def bulk_delete(*uids)
      @memory.bulk_delete(*uids)
    end

    def all
      @memory.all
    end

    def size
      @memory.size
    end

    protected

    def service(service_name)
      @services[service_name] || raise(no_service_error service_name)
    end

    def no_service_error(service_name)
      NotImplementedError.new("#{service_name} service in #{self.class}")
    end

    def map(entity_name, entity)
      gateway = gateway_for_entity(entity_name)

      if entity.uid
        result = gateway.update(entity)
      else
        result = gateway.add(entity)
      end

      result.uid
    end

    def unmap(entity_name, uid)
      gateway_for_entity(entity_name).get(uid)
    end

    def gateway_for_entity(entity_name)
      service(:"#{entity_name}_gateway")
    end
  end
end
