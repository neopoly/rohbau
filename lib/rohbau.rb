require "rohbau/version"

# Rohbau provides a set of patterns used in Domain Driven Design.
#
# Require individual parts of Rohbau to use its functionality
#
# @example
#     require 'rohbau/runtime'
#     require 'rohbau/runtime_loader'
#     module MyApplication
#       class RuntimeLoader < Rohbau::RuntimeLoader
#         def initialize
#           super(Runtime)
#         end
#       end
#
#       class Runtime < Rohbau::Runtime
#       end
#     end
#
# @see README for more examples
module Rohbau
end
