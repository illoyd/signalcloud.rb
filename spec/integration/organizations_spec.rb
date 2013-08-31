require 'spec_helper'

describe SignalCloud::Client do
  let(:client) { test_client }

  describe '#organizations' do
    it 'returns a list of organizations' do
      client.organizations.should_not be_empty
    end
  end

  describe '#organization' do
    let!(:organization_id) { client.organizations.first.id }
    
    it 'returns an organization object' do
      client.organization(organization_id).should be_a( SignalCloud::Organization )
    end
    it 'returns the requested organization' do
      client.organization(organization_id).id.should == organization_id
    end
  end

end
