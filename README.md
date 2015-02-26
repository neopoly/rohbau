[github]: https://github.com/neopoly/rohbau
[doc]: http://rubydoc.info/github/neopoly/rohbau/master/file/README.md
[gem]: https://rubygems.org/gems/rohbau
[gem-badge]: https://img.shields.io/gem/v/rohbau.svg
[travis]: https://travis-ci.org/neopoly/rohbau
[travis-badge]: https://img.shields.io/travis/neopoly/rohbau.svg?branch=master
[codeclimate]: https://codeclimate.com/github/neopoly/rohbau
[codeclimate-climate-badge]: https://img.shields.io/codeclimate/github/neopoly/rohbau.svg
[codeclimate-coverage-badge]: https://codeclimate.com/github/neopoly/rohbau/badges/coverage.svg
[inchpages]: https://inch-ci.org/github/neopoly/rohbau
[inchpages-badge]: https://inch-ci.org/github/neopoly/rohbau.svg?branch=master&style=flat

# Rohbau

[![Travis][travis-badge]][travis]
[![Gem Version][gem-badge]][gem]
[![Code Climate][codeclimate-climate-badge]][codeclimate]
[![Test Coverage][codeclimate-coverage-badge]][codeclimate]
[![Inline docs][inchpages-badge]][inchpages]

[Gem][gem] |
[Source][github] |
[Documentation][doc]

## Description

Rohbau provides a set of patterns used in Domain Driven Design.

## Installation

Add this line to your application's Gemfile:

    gem 'rohbau'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rohbau

## Usage

### Runtime

By instantiation of the `RuntimeLoader`, an instance of the `Runtime`is created and stored as a singleton.
Internal units of the respective component can access this instance by referring to the `RuntimeLoader`.
By this a place is made where for example memories for in-memory gateway backend implementations can be stored.


```ruby
require 'rohbau/runtime'
require 'rohbau/runtime_loader'

module MyApplication
  class RuntimeLoader < Rohbau::RuntimeLoader
    def initialize
      super(Runtime)
    end
  end

  class Runtime < Rohbau::Runtime
  end
end

module UserService
  class RuntimeLoader < Rohbau::RuntimeLoader
    def initialize
      super(Runtime)
    end
  end

  class Runtime < Rohbau::Runtime
  end
end

# Register user service on my application runtime
MyApplication::Runtime.register :user_service, UserService::RuntimeLoader
MyApplication::Runtime.plugins[:user_service] # => {:user_service=>UserService::RuntimeLoader}

# Runtimes are not initialized yet
MyApplication::RuntimeLoader.instance # => nil
MyApplication::Runtime.plugins[:user_service].instance # => nil

# Boot my application runtime
MyApplication::RuntimeLoader.running? # => false
MyApplication::RuntimeLoader.new
MyApplication::RuntimeLoader.running? # => true

# Runtimes are initialized
MyApplication::RuntimeLoader.instance # => #<MyApplication::Runtime:0x00000000f5b8d8 @user_service=UserService::RuntimeLoader>
MyApplication::Runtime.plugins[:user_service].instance # => #<UserService::Runtime:0x00000000b1ecc0>

# Runtimes are singletons
MyApplication::RuntimeLoader.instance === MyApplication::RuntimeLoader.instance
MyApplication::Runtime.plugins[:user_service].instance === MyApplication::Runtime.plugins[:user_service].instance

# Terminate my application runtime
MyApplication::RuntimeLoader.terminate
MyApplication::RuntimeLoader.running? # => false

```

### ServiceFactory

The `ServiceFactory` is considered the authority for retrieval of service instances.
It follows partly the service locator / registry pattern.

#### Examples

Register and unregister default service and override with specific service.

```ruby
include_example service_factory
```

Validate registered dependencies

```ruby
MyServiceFactory.external_dependencies :user_service
MyServiceFactory.missing_dependencies # => [:user_service] 
MyServiceFactory.external_dependencies_complied? # => false

MyServiceFactory.register(:user_service) { Object.new } # => :user_service 
MyServiceFactory.external_dependencies_complied? # => true 
MyServiceFactory.missing_dependencies # => [] 
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
