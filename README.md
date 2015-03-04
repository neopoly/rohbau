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

_Rohbau_ provides a set of patterns used in Domain Driven Design.

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

#### Examples

Inject a user service to your application

`examples/my_application.rb`

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

```

`examples/user_service/runtime.rb`

```ruby
require 'rohbau/runtime'
require 'rohbau/runtime_loader'

module UserService
  class RuntimeLoader < Rohbau::RuntimeLoader
    def initialize
      super(Runtime)
    end
  end

  class Runtime < Rohbau::Runtime
  end
end

```

`examples/user_service/runtime.rb`

```ruby
require 'my_application'
require 'user_service/runtime'

# Register user service on my application runtime
MyApplication::Runtime.register :user_service, UserService::RuntimeLoader

# My application runtime knowns about the registered plugins
MyApplication::Runtime.plugins # => {:user_service=>UserService::RuntimeLoader}

# The registered plugin knows his registrar
UserService::RuntimeLoader.registrar # => MyApplication::Runtime

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

`examples/user_service/service_factory.rb`

```ruby
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

```

Validate registered dependencies

`examples/user_service/service_factory_validation.rb`

```ruby
require 'rohbau/service_factory'

MyServiceFactory = Class.new(Rohbau::ServiceFactory)

MyServiceFactory.external_dependencies :user_service
MyServiceFactory.missing_dependencies # => [:user_service] 
MyServiceFactory.external_dependencies_complied? # => false

MyServiceFactory.register(:user_service) { Object.new } # => :user_service 
MyServiceFactory.external_dependencies_complied? # => true 
MyServiceFactory.missing_dependencies # => [] 

```

### Request

It ensures an initialized runtime and builds up a new the service factory instance.

```ruby
require 'rohbau/request'
require 'user_service/service_factory'

module UserService
  class Request < Rohbau::Request
    def initialize(runtime = RuntimeLoader.instance)
      super(runtime)
    end

    protected

    def build_service_factory
      ServiceFactory.new(@runtime)
    end
  end
end

```

### Entity

Entities are low level, logic-less, data structures. 

`examples/user_entity.rb`

```ruby
require 'rohbau/entity'

class User < Rohbau::Entity
  attributes :nickname
end

bob = User.new
bob.nickname = 'Bob'
bob.nickname # => 'Bob'

other_bob = User.new
other_bob.nickname = 'Bob'
other_bob.nickname # => 'Bob'

bob == other_bob # => true

```

### Gateway

tbd

### UseCase

`UseCases` define the interface for the end user who interacts with the system.

#### Examples

`examples/user_service/create_user_use_case.rb`

```ruby
require 'rohbau/use_case'

module UserService
  def self.create(user_data)
    print "Created user #{user_data[:nickname]}"
  end
end

module UserService
  class CreateUser < Rohbau::UseCase
    def initialize(request, user_data)
      super(request)
      @user_data = user_data
    end

    def call
      service(:user_service).create(@user_data)
    end
  end
end

```

`examples/use_case.rb`

```ruby
require 'user_service/runtime'
require 'user_service/request'
require 'user_service/create_user_use_case'

# Boot up user service
UserService::RuntimeLoader.new

request = UserService::Request.new

UserService::CreateUser.new(request, {:nickname => 'Bob'}).call # => 'Created user Bob'

```

### EventTube

The `EventTube` implements the `Observer` pattern. You can subscribe to events and publish them.

#### Examples

`examples/email_service/email_service.rb`

```ruby
class EmailService
  def self.send_user_registration_email_to(user)
    print "Send out email to #{user[:nickname]}"
  end
end

```

`examples/user_service/event_tube.rb`

```ruby
require 'rohbau/event_tube'

module UserRegister
  class EventTube < Rohbau::EventTube
  end

  def self.create_user(user)
    EventTube.publish :user_registered, UserRegisteredEvent.new(user)
  end

  class UserRegisteredEvent < Struct.new(:user)
  end
end

```

## Build README

Make changes to `README.md.template`, not to `README.md`

Include examples with

```bash
include_example 'example_file_name'
```

Build README.md with

```bash
  ./bin/build_readme
```

Always commit `README.md.template` and `README.md` together.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
