require 'minitest/autorun'
require 'minitest/spec'

if ENV['coverage']
  require 'simplecov'
  SimpleCov.start
end
