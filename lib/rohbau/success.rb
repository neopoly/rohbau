require 'bound'

module Rohbau
  class Success < Bound
    def self.new_bound_class
      Class.new(StaticBoundClass) do |cls|
        cls.define_singleton_method(:success?) { true }
        cls.define_singleton_method(:failure?) { false }
      end
    end
  end
end
