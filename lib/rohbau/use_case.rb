require 'bound'

module Rohbau
  class UseCase
    def self.call(request, input = nil)
      args = [request]
      args << input if input

      new(*args).call
    end

    def initialize(request)
      @request = request
    end

    protected

    def service(service_name)
      @request.services.public_send service_name
    end
  end
end
