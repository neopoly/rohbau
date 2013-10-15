require 'thread_safe'

module Rohbau
  class Index
    include Enumerable

    def initialize
      @last_uid = 0
      @entities = ThreadSafe::Hash.new

      @validator = Validator.new(self)

      @options = {
        :uid_generation => true,
        :mapper         => DefaultMapper,
        :unmapper       => DefaultMapper
      }
    end

    def add(entity)

      if option?(:uid_generation)
        validate :add, entity

        added_entity = copy(entity).tap do |new_entity|
          new_entity.uid = next_uid
          entities[new_entity.uid] = map(new_entity)
        end
      else
        validate :add_with_uid, entity

        added_entity = copy(entity).tap do |new_entity|
          entities[new_entity.uid] = map(new_entity)
        end
      end

      get added_entity.uid
    end

    def bulk_add(entities)
      entities.map do |entity|
        add entity
      end
    end

    def get(uid)
      validate :get, uid

      unmap(entities[uid])
    end

    def update(entity)
      validate :update, entity

      entities[entity.uid] = map(entity)

      get entity.uid
    end

    def delete(uid)
      validate :delete, uid

      unmap entities.delete(uid)
    end

    def bulk_delete(uids)
      uids.map do |uid|
        delete uid
      end
    end

    def all
      entities.values.map(&method(:unmap))
    end

    def each(&block)
      all.each(&block)
    end

    def size
      entities.size
    end

    def has_uid?(uid)
      entities.key?(uid)
    end

    def option(key, value = nil)
      if value != nil
        @options[key] = value
      else
        @options[key]
      end
    end

    def option?(key)
      !!@options[key]
    end

    private

    def map(entity)
      option(:mapper).call(entity)
    end

    def unmap(mapped_entity)
      option(:unmapper).call(mapped_entity)
    end

    def copy(entity)
      Marshal.load(Marshal.dump entity)
    end

    def next_uid
      "#{@last_uid += 1}"
    end

    def entities
      @entities
    end

    def validate(method, *args)
      @validator.public_send("validate_#{method}", *args)
    end

    class Validator
      def initialize(memory)
        @memory = memory
      end

      def validate_add(entity)
        ensure_entity!(entity)
        ensure_entity_has_no_uid!(entity)
      end

      def validate_add_with_uid(entity)
        ensure_entity!(entity)
        ensure_entity_has_uid!(entity)
        ensure_uid_type!(entity.uid)
      end

      def validate_get(uid)
        ensure_uid!(uid)
        ensure_uid_type!(uid)
      end

      def validate_update(entity)
        ensure_entity!(entity)
        ensure_entity_has_uid!(entity)
        ensure_entity_exists!(entity)
      end

      def validate_delete(uid)
        ensure_uid_exists!(uid)
      end


      private
      def ensure_uid!(uid)
        if uid.nil?
          raise argument_error('uid is missing')
        end
      end

      def ensure_uid_type!(uid)
        if !uid.kind_of?(String) || uid.size == 0
          raise argument_error('uid is invalid', uid)
        end
      end

      def ensure_entity!(entity)
        if entity.nil?
          raise argument_error('entity is invalid', entity)
        end
      end

      def ensure_entity_has_uid!(entity)
        if !entity.uid
          raise argument_error('entity has no uid', entity)
        end
      end

      def ensure_entity_has_no_uid!(entity)
        if entity.uid
          raise argument_error('entity has uid', entity)
        end
      end

      def ensure_entity_exists!(entity)
        if !@memory.has_uid?(entity.uid)
          raise argument_error('entity is unknown', entity)
        end
      end

      def ensure_uid_exists!(uid)
        if !@memory.has_uid?(uid)
          raise argument_error('uid is unknown', uid)
        end
      end

      def argument_error(error, object = nil)
        message = "#{self.class.inspect}: #{error}"
        message += ": #{object.inspect}" if object
        ArgumentError.new(message)
      end
    end

    class DefaultMapper
      def self.call(entity)
        Marshal.load(Marshal.dump entity)
      end
    end
  end
end
