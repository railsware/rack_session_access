# Rack Session Access [![Build Status](https://travis-ci.org/railsware/rack_session_access.svg?branch=master)](https://travis-ci.org/railsware/rack_session_access)

RackSessionAccess provides rack middleware for 'rack.session' environment management.

## Problem

Acceptance testing assumes that you can't directly access an applications session.
For example, if you use capybara with selenium webdriver you can't change some session values
because your tests use the same browser that accesses the application(via the backend server).

## Solution

But what if you still want to change session values?
One possible solution is to inject into the application some code that will manage the session independently.
If you use rack based framework this gem does it!

## Installation

```ruby
gem install rack_session_access
```

## Using with Rails

Add to `Gemfile`:

```ruby
gem 'rack_session_access'
```

Add RackSessionAccess middleware to rails middleware stack.
Add the following in`config/environments/test.rb`:

```ruby
[MyRailsApp]::Application.configure do |config|
  ...
  # Access to rack session
  config.middleware.use RackSessionAccess::Middleware
  ...
end
```

*Note* Ensure you include rack_session_access middleware only for *test* environment
otherwise you will have security issue.


## Using with Sinatra

Add to your sinatra application:

```ruby
class MySinatraApplication < Sinatra::Base
  enable :sessions
  use RackSessionAccess if environment == :test
  ...
end
```

If you use rspec you may prefer to inject middleware only for rspec tests:
Put into `spec/spec_helper`:

```ruby
MySinatraApplication.configure do |app|
  app.use RackSessionAccess::Middleware
end
```

## Using with Rack builder

```ruby
Rack::Builder.new do
  ...
  use Rack::Session::Cookie
  use RackSessionAccess::Middleware
  use MyRackApplication
end.to_app
```

## Testing with Capybara

Add to `spec/spec_helper.rb`

```ruby
require "rack_session_access/capybara"
```

Use:

* `page.set_rack_session` to set your desired session data
* `page.get_rack_session` to obtain your application session data
* `page.get_rack_session_key` to obtain certain key of your application session data

Example:

```ruby
require 'spec_helper'

feature "My feature" do
  given!(:user) { create(:user, email: 'jack@daniels.com') }

  scenario "logged in user access profile page" do
    page.set_rack_session(user_id: user.id)
    visit "/profile"
    expect(page).to have_content("Hi, jack@daniels.com")
  end

  scenario "visit landing page" do
    visit "/landing?ref=123"
    expect(page.get_rack_session_key('ref')).to eq("123")
  end
end
```

### Authlogic integration

```ruby
module FeatureHelpers
  def logged_as(user)
    page.set_rack_session('user_credentials' => user.persistence_token)
  end
end
```

### Devise integration

```ruby
module FeatureHelpers
  def logged_as(user)
    # Devise v3.x.x
    page.set_rack_session('warden.user.user.key' => User.serialize_into_session(user).unshift('User'))

    # Devise v4.x.x
    page.set_rack_session('warden.user.user.key' => User.serialize_into_session(user)
  end
end
```

## Authentication helper

Put corresponding implementation of `logged_as` in `spec/support/feature_helpers.rb` and include module into rspec config:

```ruby
RSpec.configure do |config|
  ...
  config.include FeatureHelpers, type: :feature
  ...
end
```
Start your scenarios with already logged in user:

```ruby
feature 'User dashboard', type: :feature do
  given(:user) { create(:user) }
  background do
    logged_as user
  end
  scenario 'User reviews a dashboard' do
    ...
  end
end
```

## Notes

Thus we use marshalized data it's possible to set any ruby object into application session hash.

Enjoy!

## Running rack_session_access tests


### Against Rails4, Sinatra, rack applications

```sh
bundle install
bundle exec rspec -fd spec/
```

### Against Rails3, Sinatra, rack applications

```sh
BUNDLE_GEMFILE=Gemfile.rails4 bundle install
BUNDLE_GEMFILE=Gemfile.rails4 bundle exec rspec -fd spec/
```

```sh
BUNDLE_GEMFILE=Gemfile.rails5 bundle install
BUNDLE_GEMFILE=Gemfile.rails5 bundle exec rspec -fd spec/
```

## Author

[Andriy Yanko](http://ayanko.github.com/)

## License

* Copyright (c) 2015 Railsware [www.railsware.com](http://www.railsware.com)
* [MIT](www.opensource.org/licenses/MIT)


## References

* [capybara](https://github.com/jnicklas/capybara)
