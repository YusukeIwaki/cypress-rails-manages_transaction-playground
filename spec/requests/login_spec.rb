require 'spec_helper'

RSpec.describe 'login' do
  include Rack::Test::Methods

  let(:app) { Application }

  it 'should login' do
    user = User.create!(name: 'hoge', login: 'user1', password: 'pass', password_confirmation: 'pass')

    expect { post('/login', { login: 'user1', password: 'pass' }) }.to change {
      ApiAccessToken.where(user: user).count
    }.by(1)
    response = JSON.parse(last_response.body)
    expect(response['success']).to eq(true)
    expect(response['user']['name']).to eq('hoge')
    api_access_token = ApiAccessToken.where(user: user).last
    expect(response['user']['access_token']['token']).to eq(api_access_token.token)
    expect(response['user']['access_token']['expires_at']).to eq(api_access_token.expires_at.to_i)

    header 'Authorization', "Bearer #{response['user']['access_token']['token']}"
    get '/current_user'
    response = JSON.parse(last_response.body)
    expect(response['success']).to eq(true)
    expect(response['user']['name']).to eq('hoge')
  end

  it 'should return 401 for login failure' do
    user = User.create!(name: 'hoge', login: 'user1', password: 'pass', password_confirmation: 'pass')

    expect { post('/login', { login: 'user1', password: '' }) }.not_to change {
      ApiAccessToken.where(user: user).count
    }
    expect { post('/login', { login: 'user1', password: 'user1' }) }.not_to change {
      ApiAccessToken.where(user: user).count
    }

    expect(last_response.status).to eq(401)
    response = JSON.parse(last_response.body)
    expect(response['success']).to eq(false)
  end

  it 'should return 401 if token expired' do
    user = User.create!(name: 'hoge', login: 'user1', password: 'pass', password_confirmation: 'pass')
    api_access_token = ApiAccessToken.create!(user: user, expires_at: 3.days.ago)

    header 'Authorization', "Bearer #{api_access_token.token}"
    get '/current_user'
    expect(last_response.status).to eq(401)
    response = JSON.parse(last_response.body)
    expect(response['success']).to eq(false)    
  end

  it 'should return 401 if invalid token is specified' do
    header 'Authorization', "Bearer aiueo"
    get '/current_user'
    expect(last_response.status).to eq(401)
    response = JSON.parse(last_response.body)
    expect(response['success']).to eq(false)    
  end

  it 'should return 401 if token is absent' do
    get '/current_user'
    expect(last_response.status).to eq(401)
    response = JSON.parse(last_response.body)
    expect(response['success']).to eq(false)    
  end
end