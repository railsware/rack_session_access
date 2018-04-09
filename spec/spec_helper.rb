require 'capybara/rspec'

require 'rack_session_access'
require 'rack_session_access/capybara'

Dir[File.expand_path('../../apps/*.rb', __FILE__)].each do |f|
  require f
end

Capybara.server = :webrick

Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new app,
    browser: ENV.fetch('SELENIUM_BROWSER', 'chrome').to_sym
end

TestSinatraApp.configure do |app|
  app.environment = :test
  app.use RackSessionAccess::Middleware
end

TestRailsApp::Application.configure do |app|
  app.middleware.use ActionDispatch::Session::CookieStore
  app.middleware.use RackSessionAccess::Middleware
end
