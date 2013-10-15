module Rohbau
  module Minitest
    module Exclude

      class SpecNuker
        def initialize(description_name, description_caller)
          spec_class = find_spec_class(description_caller)
          @description_caller   = description_caller
          @description_name     = description_name
          @description_classes  = spec_class.children
        end

        def nuke!(it_desc)
          it_method_name = find_it_method(it_desc)

          if it_method_name.nil?
            inspected_method = "\"#{@description_caller}\"##{it_desc.inspect}"
            msg = "Method #{inspected_method} is not defined"
            return warn(msg)
          end

          description_class.send :undef_method, it_method_name
        end

        private

        def find_spec_class(description_class)
          description_class.superclass
        end

        def find_it_method(it_desc)
          description_class.instance_methods.detect do |instance_method|
            instance_method =~ %r{test_[0-9]+_#{it_desc}}
          end
        end

        def description_class
          @description_classes.detect do |description_class|
            description_class.name == @description_name
          end
        end

      end

    end
  end
end

module MiniTest::Spec::DSL


  # only single nesting in one describe block is supported
  # for now
  def exclude(it_desc, reason = "")
    Rohbau::Minitest::Exclude::SpecNuker.new(self.name, self).nuke!(it_desc)
  end

end
