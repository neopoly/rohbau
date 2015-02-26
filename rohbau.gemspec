# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rohbau/version'

Gem::Specification.new do |spec|
  spec.name          = "rohbau"
  spec.version       = Rohbau::VERSION
  spec.authors       = [
    "Jakob Holderbaum",
    "Peter Suschlik",
    "Dax Defranco",
    "Andreas Busold",
    "Jan Owiesniak"
  ]
  spec.email         = [
    "rohbau@jakob.io",
    "ps@neopoly.de",
    "dd@neopoly.de",
    "ab@neopoly.de",
    "jo@neopoly.de"
  ]
  spec.summary       = %q{Provides a set of patterns used in Domain Driven Design}
  spec.homepage      = "http://www.neopoly.de/"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'thread_safe', '~> 0.3'
  spec.add_dependency 'bound', '~> 2.1'

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.3'
  spec.add_development_dependency 'minitest', '~> 5.4'
  spec.add_development_dependency 'simplecov'
end
