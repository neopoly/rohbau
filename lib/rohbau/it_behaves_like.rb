require 'minitest/spec'

module Rohbau
  module ItBehavesLike

    def get_shared_example(spec)
      shared_specs_namespace::SharedSpec.get(spec)
    end

    def it_behaves_like(spec)
      if spec.kind_of? Proc
        shared_example = spec
      else
        shared_example = get_shared_example(spec)
      end
      raise "No shared spec for #{spec.inspect} found" unless shared_example

      instance_eval(&shared_example)
    end

  end
end

class MiniTest::Spec
  extend Rohbau::ItBehavesLike
end
