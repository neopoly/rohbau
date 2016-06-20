require 'bound'

module Rohbau
  class Success < Bound
    def self.new_bound_class
      Class.new(StaticBoundClass) do |cls|
        cls.send(:define_method, :success?) { true }
        cls.send(:define_method, :failure?) { false }
      end
    end
  end
end
