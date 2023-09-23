# frozen_string_literal: true

require 'bundler'
Bundler.require :default, (ENV['RACK_ENV'] || :development).to_sym

require_relative './config/activerecord'
require_relative './config/zeitwerk'
require 'sinatra/base'
require 'sinatra/jbuilder'

class Application < Sinatra::Base
  use Rack::JSONBodyParser
  set :show_exceptions, false

  get '/' do
    '<h1>It works!</h1>'
  end

  post '/login' do
    @user = User.authenticate(params['login'], params['password'])
    unless @user
      halt 401, { success: false }.to_json
    end

    @api_access_token = ApiAccessToken.create!(user: @user)
    jbuilder :'login.json'
  end

  helpers do
    def api_login_required
      unless @api_current_user = api_current_user
        halt 401, { success: false }.to_json
      end
    end

    def api_current_user
      unless (authorization = request.env['HTTP_AUTHORIZATION'])
        return nil
      end

      unless (match = authorization.match(/Bearer (.*)/))
        return nil
      end

      User.api_authenticate(match[1])
    end
  end

  get '/current_user' do
    api_login_required

    jbuilder :'current_user.json'
  end
end