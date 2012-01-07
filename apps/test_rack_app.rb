require 'rack'

TestRackApp = Rack::Builder.new do
  use Rack::Session::Cookie
  use RackSessionAccess::Middleware
  run lambda { |env| [200, { 'Content-Type' => 'text/plain'}, [ "DUMMY"] ] }
end.to_app
