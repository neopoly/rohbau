require 'rohbau/it_behaves_like'
require 'rohbau/minitest/exclude'

module Rohbau
  class SharedSpec < Proc

    def self.for(name, &block)
      @shared_specs ||= {}
      @shared_specs[name] = new(&block)
    end

    def self.get(name)
      @shared_specs ||= {}
      @shared_specs[name]
    end

  end
end

