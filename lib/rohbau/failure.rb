require 'bound'

module Rohbau
  class Failure < Bound
    private

    def self.new_bound_class
      Class.new(StaticBoundClass) do |cls|
        cls.define_singleton_method(:success?) { false }
        cls.define_singleton_method(:failure?) { true }
      end
    end
  end
end
