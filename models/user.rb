class User < ActiveRecord::Base
  validates :name, presence: true

  has_secure_password

  def self.authenticate(login, password)
    User.find_by(login: login)&.authenticate(password) || nil
  end

  def self.api_authenticate(token)
    ApiAccessToken.find_by(expires_at: Time.now.., token: token)&.user
  end
end
