require 'spec_helper'

RSpec.describe User do
  let!(:user) {
    User.create!(name: 'John', login: 'doe', password: 'hogehoge', password_confirmation: 'hogehoge')
  }

  it 'should authenticate by login password' do
    expect(User.authenticate('', '')).to be_nil
    expect(User.authenticate('John', '')).to be_nil
    expect(User.authenticate('doe', '')).to be_nil
    expect(User.authenticate('doe', nil)).to be_nil
    expect(User.authenticate('doe', 'hogehogehoge')).to be_nil
    expect(User.authenticate('', 'hogehoge')).to be_nil
    expect(User.authenticate(nil, 'hogehoge')).to be_nil
    expect(User.authenticate('John', 'hogehoge')).to be_nil
    expect(User.authenticate('doe', 'hogehoge').attributes).to eq(user.attributes) 
  end

  it 'should authenticate by api access token' do
    ApiAccessToken.create!(user: user, token: "xxx", expires_at: 3.days.ago)
    expect(User.api_authenticate('xxx')).to be_nil
    ApiAccessToken.create!(user: user, token: "yyy", expires_at: Time.now + 1)
    expect(User.api_authenticate('yyy').attributes).to eq(user.attributes)
  end

  it 'should generate random access tokens' do
    token1 = ApiAccessToken.create!(user: user)
    token2 = ApiAccessToken.create!(user: user)

    expect(token1.token).not_to eq(token2.token)
  end
end