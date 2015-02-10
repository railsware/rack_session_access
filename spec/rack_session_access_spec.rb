require 'spec_helper'

describe RackSessionAccess do
  subject { described_class }

  it 'should have configured default path' do
    expect(subject.path).to eq('/rack_session')
  end

  it 'should have configured default edit_path' do
    expect(subject.edit_path).to eq('/rack_session/edit')
  end

  describe '.encode' do
    it 'should encode ruby hash to string' do
      result = subject.encode( { 'a' => 'b' })
      expect(result).to be_kind_of(String)
    end
  end

  describe '.decode' do
    it 'should decode marshalized and base64 encoded string' do
      # Array(Marshal.dump({ :user_id => 100 })).pack("m")
      # => "BAh7BjoMdXNlcl9pZGlp\n"
      expect(subject.decode("BAh7BjoMdXNlcl9pZGlp\n")).to eq(user_id: 100)
    end
  end

  it 'should encode and decode value' do
    source = { 'klass' => Class, :id => 100, '1' => 2 }
    data = subject.encode(source)
    result = subject.decode(data)
    expect(result).to eq(source)
  end

  it 'should encode and decode values with line brake characters' do
    source = { 'line' => "one\ntwo" }
    data = subject.encode(source)
    result = subject.decode(data)
    expect(result).to eq(source)
  end
end
