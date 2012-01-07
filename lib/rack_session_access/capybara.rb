module RackSessionAccess
  module Capybara
    def set_rack_session(hash)
      data = ::RackSessionAccess.encode(hash)

      visit ::RackSessionAccess.edit_path
      has_content?("Update rack session")
      fill_in "data", :with => data
      click_button "Update"
      has_content?("Rack session data")
    end
  end
end

require 'capybara/session'
Capybara::Session.send :include, RackSessionAccess::Capybara
