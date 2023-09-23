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

  get '/users' do
    @users = User.all
    jbuilder :"users.json"
  end
end
