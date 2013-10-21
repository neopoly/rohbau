module Rohbau

  class Entity
    class << self; attr_accessor :__attributes__ end
    def self.attributes(*attributes)
      @__attributes__ ||= []
      @__attributes__ += attributes


      predicate_attributes = attributes.select do |attr|
        attr =~ /\?$/
      end

      regular_attributes = attributes - predicate_attributes

      predicate_attributes.each do |attribute|
        attribute_without_predicate = attribute.to_s.gsub(/\?$/, '')
        attr_accessor attribute_without_predicate

        define_method attribute do ||
          !!instance_variable_get(:"@#{attribute_without_predicate}")
        end
      end

      attr_accessor(*regular_attributes)
    end

    def ==(other)
      other && __attributes__.all? do |attr|
        other.respond_to?(attr) &&
          self.public_send(attr) == other.public_send(attr)
      end
    end

    protected
    def __attributes__
      self.class.__attributes__ || []
    end
  end

end
