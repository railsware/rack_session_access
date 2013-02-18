require 'spec_helper'

shared_examples "common scenarios" do
  let(:data) do
    {
      'user_email'   => 'jack@daniels.com',
      'user_profile' => { :age => 12 },
      'role_ids'     => [1, 20, 30]
    }
  end

  scenario "changing session data" do
    page.visit RackSessionAccess.edit_path
    page.should have_content("Update rack session")

    page.fill_in "data", :with => RackSessionAccess.encode({'user_id' => 1})
    page.click_button "Update"
    page.should have_content("Rack session data")
    page.should have_content('"user_id" : 1')
    page.current_path.should == RackSessionAccess.path
  end

  scenario "providing no session data" do
    page.visit RackSessionAccess.edit_path
    page.should have_content("Update rack session")

    page.click_button "Update"
    page.should have_content("Bad data")
    page.current_path.should == RackSessionAccess.path
  end

  scenario "providing bad data" do
    page.visit RackSessionAccess.edit_path
    page.should have_content("Update rack session")

    page.fill_in "data", :with => "qwertyuiop"
    page.click_button "Update"
    page.should have_content("Bad data")
    page.current_path.should == RackSessionAccess.path
  end

  scenario "modify session data with set_rack_session helper" do
    page.set_rack_session(data)

    page.visit(RackSessionAccess.path)
    page.should have_content('"user_email" : "jack@daniels.com"')
    page.should have_content('"user_profile" : {:age=>12}')
    page.should have_content('"role_ids" : [1, 20, 30]')
  end

  scenario "accessing raw session data" do
    page.set_rack_session(data)

    page.visit(RackSessionAccess.path + '.raw')
    raw_data = page.find(:xpath, "//body/pre").text
    raw_data.should be_present
    actual_data = RackSessionAccess.decode(raw_data)
    actual_data.should be_kind_of(Hash)
    data.each do |key, value|
      actual_data[key].should == value
    end
  end

  scenario "accessing raw session data using get_rack_session helper" do
    page.set_rack_session(data)

    actual_data = page.get_rack_session

    actual_data.should be_kind_of(Hash)
    data.each do |key, value|
      actual_data[key].should == value
    end
  end

  scenario "accessing raw session data using get_rack_session_key helper" do
    page.set_rack_session(data)

    page.get_rack_session_key('role_ids').should == [1, 20, 30]
  end
end

shared_examples "rack scenarios" do
  scenario "accessing application" do
    page.visit "/welcome"
    page.text.should == "DUMMY"
  end
end

shared_examples "sinatra scenarios" do
  scenario "test application itself" do
    page.visit "/login"
    page.should have_content("Please log in")

    page.visit "/profile"
    page.should have_content("Please log in")
  end

  scenario "accessing application" do
    page.visit "/profile"
    page.text.should == "Please log in"

    page.set_rack_session({:user_email => "jack@daniels.com"})

    page.visit "/profile"
    page.text.should == "Welcome, jack@daniels.com!"
  end
end

shared_examples "rails scenarios" do
  scenario "test application itself" do
    page.visit "/login"
    page.should have_content("Please log in")

    page.visit "/profile"
    page.should have_content("Please log in")
  end

  scenario "accessing application" do
    page.visit "/profile"
    page.text.should == "Please log in"

    page.set_rack_session({:user_email => "jack@daniels.com"})

    page.visit "/profile"
    page.text.should == "Welcome, jack@daniels.com!"
  end
end

feature "manage rack session", %q(
  As developer
  I want to have ability to modify rack session
  So I can write faster tests
) do

  context ":rack_test driver", :driver => :rack_test do
    context "rack application" do
      background { Capybara.app = TestRackApp }
      include_examples "common scenarios"
      include_examples "rack scenarios"
    end

    context "sinatra application" do
      background { Capybara.app = TestSinatraApp }
      include_examples "common scenarios"
      include_examples "sinatra scenarios"
    end

    context "rails application" do
      background { Capybara.app = TestRailsApp::Application }
      include_examples "common scenarios"
      include_examples "rails scenarios"
    end
  end



  context ":selenium driver", :driver => :selenium do
    context "rack application" do
      background { Capybara.app = TestRackApp }
      include_examples "common scenarios"
      include_examples "rack scenarios"
    end

    context "sinatra application" do
      background { Capybara.app = TestSinatraApp }
      include_examples "common scenarios"
      include_examples "sinatra scenarios"
    end

    context "rails application" do
      background { Capybara.app = TestRailsApp::Application }
      include_examples "common scenarios"
      include_examples "rails scenarios"
    end
  end

end
