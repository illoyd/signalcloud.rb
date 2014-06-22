require 'spec_helper'

describe SignalCloud::Client do
  let(:service_uri) { 'http://localhost:5000' }
  let(:client)      { SignalCloud::Client.new( username, password, base_uri: service_uri) }  

  context 'when valid' do
    let(:username)  { ENV['SIGNALCLOUD_TEST_USERNAME'] }
    let(:password)  { ENV['SIGNALCLOUD_TEST_PASSWORD'] }
    it 'does not raise an error' do
      expect{ client.organizations }.not_to raise_error
    end
  end

  context 'when invalid' do
    let(:username)  { 'bad' }
    let(:password)  { 'credential' }
    it 'raises invalid credential error' do
      expect{ client.organizations }.to raise_error(SignalCloud::InvalidCredentialError)
    end
  end
  
  context 'when providing bogus organization options' do
    let(:client) { test_client }
    it 'raises not found' do
      expect{ client.organization(-1) }.to raise_error(SignalCloud::ObjectNotFoundError)
    end
    it 'raises misc error' do
      pending('Need to configure server to not redirect when format is JSON.')
      expect{ client.organization(2) }.to raise_error(SignalCloud::SignalCloudError)
    end
  end

end
