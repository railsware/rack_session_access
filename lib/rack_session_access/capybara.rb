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

    def get_rack_session
      visit ::RackSessionAccess.path + '.raw'
      has_content?("Raw rack session data")
      raw_data = find(:xpath, '//body/pre').text
      ::RackSessionAccess.decode(raw_data)
    end

    def get_rack_session_key(key)
      get_rack_session.fetch(key)
    end
  end
end

require 'capybara/session'
Capybara::Session.send :include, RackSessionAccess::Capybara
