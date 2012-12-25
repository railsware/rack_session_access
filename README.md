# rack_session_access

RackSessionAccess provides rack middleware for 'rack.session' environment management.

## Problem

Acceptance testing assumes that you can't directly access application session.
For example if you use capybara with selenium webdriver you can't change some session value
because your test use browser that access application via backend server.

## Solution

But if you still want to change session values?
Possible solution is inject into application some code that will manage session.
If you use rack based framework this gem does it!

## Installation

    gem install rack_session_access

## Using with Rails3

Add to `Gemfile`:

    gem 'rack_session_access'

Add RackSessionAccess middleware to rails middleware stack.
Add the following in`config/environments/test.rb`:

    [MyRailsApp]::Application.configure do
      ...
      # Access to rack session
      config.middleware.use RackSessionAccess::Middleware
      ...
    end

*Note* Ensure you include rack_session_access middleware only for *test* environment
otherwise you will have security issue.


## Using with Sinatra

Add to your sinatra application:

    class MySinatraApplication < Sinatra::Base
      enable :sessions
      use RackSessionAccess if environment == :test
      ...
    end

If you use rspec you may prefer to inject middleware only for rspec tests:
Put into `spec/spec_helper`:

      MySinatraApplication.configure do
        use RackSessionAccess::Middleware
      end

## Using with Rack builder

    Rack::Builder.new do
      ...
      use Rack::Session::Cookie
      use RackSessionAccess::Middleware
      use MyRackApplication
    end.to_app

## Testing with Capybara

Add to `spec/spec_helper.rb`

    require "rack_session_access/capybara"

And use `page.set_rack_session` to set your desired session data!

Example:

    require 'spec_helper'

    feature "My feature" do
      background do
        @user = Factory(:user, :email => 'jack@daniels.com')
      end

      scenario "logged in user access profile page" do
        page.set_rack_session(:user_id => user.id)
        page.visit "/profile"
        page.should have_content("Hi, jack@daniels.com")
      end
    end

## Authlogic integration

    page.set_rack_session("user_credentials" => @user.persistence_token)

## Devise integration

    page.set_rack_session("warden.user.user.key" => User.serialize_into_session(@user).unshift("User"))

## Notes

Thus we use marshalized data it's possible to set any ruby object into application session hash.

Enjoy!


## References

* [capybara](https://github.com/jnicklas/capybara)
