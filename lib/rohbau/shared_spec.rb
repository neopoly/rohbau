require 'rohbau/it_behaves_like'
require 'rohbau/minitest/exclude'

module Rohbau
  class SharedSpec < Proc
    def self.for(name, &block)
      shared_specs[name] = Proc.new(&block)
    end

    def self.get(name)
      shared_specs[name]
    end

    def self.inherited(child_class)
      SpecIndex.register child_class
    end

    def self.shared_specs
      @shared_specs ||= {}
    end

    class SpecIndex
      def self.reset
        @specs = []
      end

      def self.register(shared_spec_class)
        reset unless @specs
        @specs << shared_spec_class
      end

      def self.all
        @specs.dup
      end

      def self.get(name)
        @specs.each do |spec|
          found = spec.get(name)
          return found if found
        end
        nil
      end
    end
  end
end
