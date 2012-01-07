require 'capybara/rspec'

require 'rack_session_access'
require 'rack_session_access/capybara'

Dir[File.expand_path('../../apps/*.rb', __FILE__)].each do |f|
  require f
end

TestSinatraApp.configure do |app|
  app.environment = :test
  app.use RackSessionAccess::Middleware
end

TestRailsApp::Application.configure do |app|
  app.middleware.use RackSessionAccess::Middleware
end
