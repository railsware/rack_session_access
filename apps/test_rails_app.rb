require 'action_controller/railtie'

module TestRailsApp
  class Application < Rails::Application
    config.secret_token = '572c86f5ede338bd8aba8dae0fd3a326aabababc98d1e6ce34b9f5'
    if Rails::VERSION::MAJOR > 3
      config.secret_key_base = '6dfb795086781f017c63cadcd2653fac40967ac60f621e6299a0d6d811417156d81efcdf1d234c'
    end

    routes.draw do
      get  '/login'   => 'test_rails_app/sessions#new'
      post '/login'   => 'test_rails_app/sessions#create'
      get  '/profile' => 'test_rails_app/profiles#show'
    end
  end

  class SessionsController < ActionController::Base
    def new
      render :text => "Please log in"
    end

    def create
      session[:user_email] = params[:user_email]
      redirect_to '/profile'
    end
  end

  class ProfilesController < ActionController::Base
    def show
      if user_email = session[:user_email]
        render :text => "Welcome, #{user_email}!"
      else
        redirect_to '/login' 
      end
    end
  end
end

Rails.logger = Logger.new('/dev/null')
