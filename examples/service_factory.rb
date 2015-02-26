require 'rohbau/service_factory'

MyServiceFactory = Class.new(Rohbau::ServiceFactory)

user_service_1 = Struct.new(:users).new([:alice, :bob])
user_service_2 = Struct.new(:users).new([:jim, :kate])

runtime = Object.new
registry = MyServiceFactory.new(runtime)

MyServiceFactory.register(:user_service) { user_service_1 }
registry.user_service.users # => [:alice, :bob]

MyServiceFactory.register(:user_service) { user_service_2 }
registry.user_service.users # => [:jim, :kate]

MyServiceFactory.unregister(:user_service)
registry.user_service.users # => [:alice, :bob]

MyServiceFactory.unregister(:user_service)
registry.user_service # => NoMethodError: undefined method `user_service'
