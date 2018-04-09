# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "rack_session_access/version"

Gem::Specification.new do |s|
  s.name        = "rack_session_access"
  s.version     = RackSessionAccess::VERSION
  s.authors     = ["Andriy Yanko"]
  s.email       = ["andriy.yanko@gmail.com"]
  s.homepage    = "https://github.com/railsware/rack_session_access"
  s.summary     = %q{Rack middleware that provides access to rack.session environment}
  s.license     = 'MIT'

  s.rubyforge_project = "rack_session_access"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "rack", ">=1.0.0"
  s.add_runtime_dependency "builder", ">=2.0.0"

  s.add_development_dependency 'rspec', '~>3.7.0'
  s.add_development_dependency 'capybara', '~>3.0.1'
  s.add_development_dependency 'chromedriver-helper'
  s.add_development_dependency 'selenium-webdriver', '~>3.11.0'
  s.add_development_dependency 'rails', '>=4.0.0'
end
