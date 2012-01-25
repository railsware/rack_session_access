require 'spec_helper'

describe RackSessionAccess do
  subject { described_class }

  its(:path) { should ==  '/rack_session' }

  its(:edit_path) { should == '/rack_session/edit' }

  describe ".encode" do
    it "should encode ruby hash to string" do
      result = subject.encode( { 'a' => 'b' })
      result.should be_kind_of(String)
    end
  end

  describe ".decode" do
    it "should decode marshalized and base64 encoded string" do
      # Array(Marshal.dump({ :user_id => 100 })).pack("m")
      # => "BAh7BjoMdXNlcl9pZGlp\n"
      subject.decode("BAh7BjoMdXNlcl9pZGlp\n").should == { :user_id => 100 }
    end
  end

  it "should encode and decode value" do
    source = { 'klass' => Class, :id => 100, '1' => 2 }
    data = subject.encode(source)
    result = subject.decode(data)
    result.should == source
  end

  it "should encode and decode values with line brake characters" do
    source = { 'line' => "one\ntwo" }
    data = subject.encode(source)
    result = subject.decode(data)
    result.should == source
  end
end
