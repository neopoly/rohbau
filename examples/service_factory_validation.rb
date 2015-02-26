require 'rohbau/service_factory'

MyServiceFactory = Class.new(Rohbau::ServiceFactory)

MyServiceFactory.external_dependencies :user_service
MyServiceFactory.missing_dependencies # => [:user_service] 
MyServiceFactory.external_dependencies_complied? # => false

MyServiceFactory.register(:user_service) { Object.new } # => :user_service 
MyServiceFactory.external_dependencies_complied? # => true 
MyServiceFactory.missing_dependencies # => [] 
