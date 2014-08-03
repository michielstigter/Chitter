require 'data_mapper'
require 'sinatra'
require 'rack-flash'
require './lib/user'
require_relative 'helpers/application'
require_relative 'data_mapper_setup'
require_relative 'messaging'

enable :sessions
set :session_secret, 'super secret'

use Rack::Flash
set :views, './app/views'



  get '/' do
    erb :index
  end

  get '/users/new' do
  	@user = User.new
  	erb :"users/new"
  end

  post '/users' do
  	email = params[:email]
  	password = params[:password]
  	password_confirmation = params[:password_confirmation]
  	name = params[:name]
  	username = params[:username]
  	@user = User.create(:email => email, :password => password, :password_confirmation => password_confirmation, :name => name, :username => username)
 	if @user.save
      session[:user_id] = @user.id
      redirect to('/users/session')
  else 
    flash.now[:errors] = @user.errors.full_messages
    erb :"users/new"
  end
end

 post '/users/session' do
  email, password = params[:email], params[:password]
  @user = User.authenticate(email, password)
  if @user
    session[:user_id] = @user.id
    redirect to('/users/session')
  else
    flash[:errors] = ["The email or password is incorrect"]
    erb :"session/new"
  end
 end

 get '/users/session' do
  	erb :"users/session"
 end

 get '/session/new' do
    erb :"session/new"
 end

 delete '/users/session' do
   flash[:notice] = "Good bye!"
  session[:user_id] = nil
  redirect to('/')
 end

 post '/session/forgot_login' do
  email = params[:email]
  user = User.first[:email => email]
  password_token = (1..40).map{('A'..'Z').to_a.sample}.join
  password_token_timestamp = Time.now
  user.update(:password_token => password_token, :password_token_timestamp => password_token_timestamp)

  Messaging.send_email(user)
  flash[:notice] = "Password reset email sent"
  redirect to('/')

  end






