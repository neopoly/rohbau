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
