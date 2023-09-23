class ApiAccessToken < ActiveRecord::Base
  belongs_to :user

  attribute :token, default: -> { SecureRandom.hex(32) }
  attribute :expires_at, default: -> { 60.minutes.since(Time.now) }
end