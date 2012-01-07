require 'sinatra'

class TestSinatraApp < Sinatra::Base
  enable :sessions

  get '/login' do
    body "Please log in"
  end

  post '/login' do
    session[:user_email] = params[:user_email]
    redirect to('/profile')
  end

  get '/profile' do
    if user_email = session[:user_email]
      body "Welcome, #{user_email}!"
    else
      redirect to('/login')
    end
  end
end
