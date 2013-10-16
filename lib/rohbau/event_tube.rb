module Rohbau
  class EventTube
    def self.reset
      @subscriptions = nil
    end
    def self.publish(name, event)
      subscription_handler.handle(name, event)
    end

    def self.subscribe(name, &handler)
      subscription_handler.add(name, &handler)
    end

    def self.subscription_handler
      @subscriptions ||= SubscriptionHandler.new
    end

    class SubscriptionHandler

      def add(name, &handler)
        subscriptions[name] << handler
        true
      end

      def handle(name, event)
        subscriptions[name].each do |handler|
          handler.call(event)
        end
        true
      end

      private
      def subscriptions
        @subscriptions ||= Hash.new do |h,k|
          h[k] = []
        end
      end

    end
  end
end
