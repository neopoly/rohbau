module Rohbau
  module RequestCache
    def self.for
      requests
    end

    def self.clear
      requests.clear
    end

    private

    def self.requests
      @requests ||= Hash.new do |hash, domain|
        hash[domain] = Object.const_get("#{domain}::Request").new
      end
    end
  end
end
