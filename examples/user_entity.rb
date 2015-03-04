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
