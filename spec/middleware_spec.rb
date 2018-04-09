require 'spec_helper'

shared_examples "common scenarios" do
  scenario "changing session data" do
    visit RackSessionAccess.edit_path
    expect(page).to have_content("Update rack session")

    fill_in "data", with: RackSessionAccess.encode({'user_id' => 1})
    click_button "Update"
    expect(page).to have_content("Rack session data")
    expect(page).to have_content('"user_id" : 1')
    expect(page.current_path).to eq(RackSessionAccess.path)
  end

  scenario "providing no session data" do
    visit RackSessionAccess.edit_path
    expect(page).to have_content("Update rack session")

    click_button "Update"
    expect(page).to have_content("Bad data")
    expect(page.current_path).to eq(RackSessionAccess.path)
  end

  scenario "providing bad data" do
    visit RackSessionAccess.edit_path
    expect(page).to have_content("Update rack session")

    fill_in "data", :with => "qwertyuiop"
    click_button "Update"
    expect(page).to have_content("Bad data")
    expect(page.current_path).to eq(RackSessionAccess.path)
  end

  scenario "modify session data with set_rack_session helper" do
    page.set_rack_session(data)

    visit(RackSessionAccess.path)
    expect(page).to have_content('"user_email" : "jack@daniels.com"')
    expect(page).to have_content('"user_profile" : {:age=>12}')
    expect(page).to have_content('"role_ids" : [1, 20, 30]')
  end

  scenario "accessing raw session data" do
    page.set_rack_session(data)

    visit(RackSessionAccess.path + '.raw')
    raw_data = find(:xpath, "//body/pre").text
    expect(raw_data).to be_present
    actual_data = RackSessionAccess.decode(raw_data)
    expect(actual_data).to be_kind_of(Hash)
    data.each do |key, value|
      expect(actual_data[key]).to eq(value)
    end
  end

  scenario "accessing raw session data using get_rack_session helper" do
    page.set_rack_session(data)

    actual_data = page.get_rack_session

    expect(actual_data).to be_kind_of(Hash)
    data.each do |key, value|
      expect(actual_data[key]).to eq(value)
    end
  end

  scenario "accessing raw session data using get_rack_session_key helper" do
    page.set_rack_session(data)

    expect(page.get_rack_session_key('role_ids')).to eq([1, 20, 30])
  end
end

shared_examples "rack scenarios" do
  scenario "accessing application" do
    visit "/welcome"
    expect(page.text).to eq("DUMMY")
  end
end

shared_examples "sinatra scenarios" do
  scenario "test application itself" do
    visit "/login"
    expect(page).to have_content("Please log in")

    visit "/profile"
    expect(page).to have_content("Please log in")
  end

  scenario "accessing application" do
    visit "/profile"
    expect(page.text).to eq("Please log in")

    page.set_rack_session(user_email: "jack@daniels.com")

    visit "/profile"
    expect(page.text).to eq("Welcome, jack@daniels.com!")
  end
end

shared_examples "rails scenarios" do
  scenario "test application itself" do
    visit "/login"
    expect(page).to have_content("Please log in")

    visit "/profile"
    expect(page).to have_content("Please log in")
  end

  scenario "accessing application" do
    visit "/profile"
    expect(page.text).to eq("Please log in")

    page.set_rack_session(user_email: "jack@daniels.com")

    visit "/profile"
    expect(page.text).to eq("Welcome, jack@daniels.com!")
  end
end

feature "manage rack session", %q(
  As developer
  I want to have ability to modify rack session
  So I can write faster tests
) do

  let(:data) do
    {
      'user_email' => 'jack@daniels.com',
      'user_profile' => {age: 12},
      'role_ids' => [1, 20, 30]
    }
  end

  context ":rack_test driver", driver: :rack_test do
    context "rack application" do
      background { Capybara.app = TestRackApp }
      include_examples "common scenarios"
      #include_examples "rack scenarios"
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

  context ":selenium driver", driver: :selenium do
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
