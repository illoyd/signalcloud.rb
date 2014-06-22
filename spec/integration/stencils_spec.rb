require 'spec_helper'

describe SignalCloud::Client do
  let(:client)           { test_client }
  let!(:organization_id) { client.organizations.first.id }
  
  describe '#stencils' do
    it 'returns a list of stencils' do
      expect( client.stencils(organization_id) ).not_to be_empty
    end
  end

  describe '#stencil' do
    let(:stencil_id)      { client.stencils(organization_id).first.id }

    it 'returns a stencil object' do
      client.stencil(organization_id, stencil_id).should be_a( SignalCloud::Stencil )
    end
    it 'returns the requested stencil' do
      client.stencil(organization_id, stencil_id).id.should == stencil_id
    end
  end

end
