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

`examples/runtime.rb`

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

`examples/user_service/request.rb`

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
  attributes :uid, :nickname

  def initialize(user_data = {})
    self.nickname = user_data[:nickname]
    super()
  end
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

Provides an interface to persist entities.

`examples/user_service/user_gateway.rb`

```ruby
require 'user_service/event_tube'
require 'user_entity'
require 'rohbau/default_memory_gateway'

module UserService
  class UserGateway < Rohbau::DefaultMemoryGateway
    def create(user_data)
      user = User.new(user_data)
      add(user)
      EventTube.publish :user_registered, UserRegisteredEvent.new(user)
    end

    class UserRegisteredEvent < Struct.new(:user)
    end
  end
end

```

### UseCase

`UseCases` define the interface for the end user who interacts with the system.

#### Examples

Define a class that inherits from `Rohbau::UseCase` which has a `#call` method:

`examples/user_service/create_user_use_case.rb`

```ruby
require 'rohbau/use_case'

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

And call the CreateUser use case as follows:

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

Alternately, use cases can be called using `Interface`, which is detailed in the next section.

### Interface

`Interface` allows for simpler and more semantic use case calling, with the additional benefit of fine grain control of return values and spy-like access in a test context.  

**Please note**: `Interface` requires an `Input` class in your use case, as well as a `Success` class if you are using the stub features.

In a nutshell, `Interface` allows your use case calls to go from this:

```ruby
require 'user_service/runtime'
require 'user_service/request'
require 'user_service/create_user_use_case'

# Boot up user service
UserService::RuntimeLoader.new

request = UserService::Request.new
input = {
  :user_data => {
    :nickname => 'Bob'
  }
}
UserService::CreateUser.new(request, input).call

```

To this:

```ruby
require 'rohbau/interface'
require 'user_service/create_user_use_case'

interface = Rohbau::Interface.instance
interface.user_service :create_user, :user_data => {
  :nickname => 'Bob'
}
```

This increased simplicity is very helpful, but the majority of `Interface`'s usefulness becomes accessible while testing. Assume the following use case:

```ruby
module UserService
  module UseCases
    class CreateUser
      Input = Bound.required :user_data
      Success = Bound.required :user_uid
      Error = Bound.required :message

      def initialize(request, input)
        @request = request
        @user_data = input.user_data
      end

      def call
        result = service(:user_service).create(@user_data)

        if result.nil?
          Error.new :message => "Something went wrong"
        else
          Success.new :user_uid => "uid_for_#{user_data.nickname}"
        end
      end
    end
  end
end
```
#### Stubbing use case return values

Let's assume this use case will be called, along with many other use cases, by the frontend framework of your choosing.  

Frontend tests should be implemented with the actual objects they would use in production, but since test isolation is an important concept in DDD, the `UserService` domain, which is outside of the scope of the frontend, should never actually be called.

Beyond this, we will also want to stub return values to create the various test cases we may have - when there is no user present, for example.  

These requirements can be realized by passing the following keys to your use case:

 * `:stub_result`
 When the `stub_result` key is present, its value will be passed to the called use case and returned in subsequent calls to that same use case as a `Success` object.
 * `:stub_type`
 Much like the `stub_result` key, the `stub_type` key allows the type of return value to be overwritten, provided, of course, that it is a type which is defined by your use case.

```ruby
require 'rohbau/interface'

describe 'stubbing use case return values' do
  let(:interface) { Rohbau::Interface.instance }

  it 'returns subsequent calls to the same use case as stubs' do
    interface.user_service :create_user, :stub_result => {
      :user_data => { :user_uid => "definitely NOT bob's uid" }
    }

    result = interface.user_service :create_user, :user_data => {
      :nickname => 'bob'
    }

    assert_kind_of UserService::UseCases::CreateUser::Success, result
    assert_equal "definitely NOT bob's uid", result.user_uid
  end

  it 'can also return other result types' do
    interface.user_service :create_user,
      :stub_type => :Error,
      :stub_result => {
        :message => "error"
      }

    result = interface.user_service :create_user

    assert_kind_of UserService::UseCases::CreateUser::Error, result
    assert_equal 'error', result.message
  end
end
```
#### Test spying

Sometimes it's helpful to look into the use case and see some details about how it has been called.  There are two methods to this end, each of which returns a hash with keys corresponding to each use case which has been called:

 * `interface.calls` is further keyed by argument and returns the value passed to the given argument.
 * `interface.call_count` returns the number of times a given use case has been called.

```ruby
require 'rohbau/interface'

describe 'spying on tests' do
  let(:interface) { Rohbau::Interface.instance }

  it 'records passed arguments by use_case' do
    interface.user_service :create_user, :user_data => {
      :nickname => 'bob'
    }

    result = interface.calls[:create_user][:user_uid]

    assert_equal "23", result
  end

  it 'records number of unstubbed calls to each use_case' do
    interface.user_service :create_user, :stub_result => {
      :user_data => { :user_uid => 'something else' }
    }

    interface.user_service :create_user, :user_data => {
      :nickname => 'bob'
    }

    interface.user_service :create_user, :user_data => {
      :nickname => 'bob'
    }

    assert_equal 2, interface.call_count[:create_user]
  end
end
```

#### Cleaning up

`Interface` provides the following two convenience methods for cleaning up your test environment:

 * `interface.clear_stubs` does what it says on the tin - All recorded arguments, call counts, stubbed results and stubbed types are cleared.
 * `interface.clear_cached_requests` empties the request cache.

```ruby
require 'rohbau/interface'

let(:interface) { Rohbau::Interface.instance }
it 'can clear all stubbed results' do
  interface.user_service :create_user, :stub_result => {
    :user_data => { :user_uid => 'something else' }
  }

  result = interface.user_service :create_user, :user_data => {
    :nickname => 'bob'
  }

  assert_equal 'something else', result.user_uid

  interface.clear_stubs

  result = interface.user_service :create_user, :user_data => {
    :nickname => 'bob'
  }

  refute_equal 'something else', result.user_uid
  assert_equal 'uid_for_bob', result.user_uid
end
```

### EventTube

The `EventTube` implements the `Publish-subscribe` pattern. You can subscribe to events and publish them.

#### Examples

`examples/email_service/email_service.rb`

```ruby
class EmailService
  def self.send_user_registration_email_to(user)
    print "Send out email to #{user.nickname}"
  end
end

```

`examples/user_service/event_tube.rb`

```ruby
require 'rohbau/event_tube'

module UserService
  class EventTube < Rohbau::EventTube
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
rake build_readme
```

Always commit `README.md.template` and `README.md` together.

## Examples

Run all examples via

```bash
rake examples
```

To verify all examples run:

```bash
rake examples:verify
```

Note: Examples will be verified during CI run.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
