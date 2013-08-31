require 'spec_helper'

describe SignalCloud::Client do

  describe '.new' do
    let(:username) { 'user' }
    let(:password) { 'pass' }

    context 'when using explicit credentials' do
      subject { SignalCloud::Client.new( username, password ) }
      its(:username) { should == username }
      its(:password) { should == password }
    end

    context 'when using environment credentials' do
      before(:each) do # Set environment variables
        ENV['SIGNALCLOUD_USERNAME'] = username
        ENV['SIGNALCLOUD_PASSWORD'] = password
      end
      after(:each) do # Purge environment variables
        ENV.delete 'SIGNALCLOUD_USERNAME'
        ENV.delete 'SIGNALCLOUD_PASSWORD'
      end
      subject { SignalCloud::Client.new() }
      its(:username) { should == username }
      its(:password) { should == password }
    end

    context 'when missing credentials' do
      before(:each) do # Purge environment variables
        ENV.delete 'SIGNALCLOUD_USERNAME'
        ENV.delete 'SIGNALCLOUD_PASSWORD'
      end
      it 'raises error on nil username' do
        expect { SignalCloud::Client.new( nil, password ) }.to raise_error
      end
      it 'raises error on nil password' do
        expect { SignalCloud::Client.new( username, nil ) }.to raise_error
      end
      it 'raises error on missing password' do
        expect { SignalCloud::Client.new( username ) }.to raise_error
      end
      it 'raises error on missing username and password' do
        expect { SignalCloud::Client.new() }.to raise_error
      end
    end
    
    context 'when providing options' do
      let(:base_uri) { 'http://localhost:5000' }
      let(:options)  {
        { base_uri: base_uri }
      }
      subject { SignalCloud::Client.new( username, password, options ) }
      its('class.base_uri') { should == base_uri }
    end

  end

end
