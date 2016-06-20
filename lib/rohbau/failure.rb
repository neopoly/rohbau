require 'bound'

module Rohbau
  class Failure < Bound
    def self.new_bound_class
      Class.new(StaticBoundClass) do |cls|
        cls.send(:define_method, :success?) { false }
        cls.send(:define_method, :failure?) { true }
      end
    end
  end
end
