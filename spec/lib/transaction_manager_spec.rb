require 'spec_helper'
require 'securerandom'

RSpec.describe TransactionManager do
  def create_user
    identifier = SecureRandom.hex(16)
    User.create!(name: "user#{identifier}", login: "login#{identifier}", password: "password#{identifier}!!!")
  end

  def fetch_users_json
    res = JSON.parse(Faraday.get('http://localhost:4000/users').body)
    res['users']
  end

  let(:instance) { TransactionManager.instance }

  it 'users are visible during transaction using TransactionManager' do
    original_count = fetch_users_json.size
    instance.begin_transaction
    3.times { create_user }
    expect(fetch_users_json.size).to eq original_count + 3
    instance.rollback_transaction
    expect(fetch_users_json.size).to eq original_count
  end

  it 'users are visible during transaction using simple ActiveRecord::Base.transaction' do
    original_count = fetch_users_json.size
    ActiveRecord::Base.transaction do
      3.times { create_user }
      expect(fetch_users_json.size).to eq original_count + 3 # Really?
      raise ActiveRecord::Rollback
    end
    expect(fetch_users_json.size).to eq original_count
  end
end
