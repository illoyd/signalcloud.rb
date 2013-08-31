require 'spec_helper'

describe SignalCloud::Client do
  let(:client)           { test_client }
  let!(:organization_id) { client.organizations.first.id }
  
  describe '#conversations' do
    it 'returns a list of conversations' do
      client.conversations(organization_id).should_not be_empty
    end
  end

  describe '#conversation' do
    let!(:conversation_id) { client.conversations(organization_id).first.id }

    it 'returns a conversation object' do
      client.conversation(organization_id, conversation_id).should be_a( SignalCloud::Conversation )
    end
    it 'returns the requested conversation' do
      client.conversation(organization_id, conversation_id).id.should == conversation_id
    end
  end
  
  describe '#start_conversation', :focus do
    let(:stencil_id) { client.stencils(organization_id).first.id } 
    let(:number) { ENV['TEST_NUMBER'] }
    let(:options) do
      {
        stencil_id: stencil_id,
        to_number: number
      }
    end
    
    it 'starts a new conversation from a stencil' do
      conversation = nil
      expect{ conversation = client.start_conversation( organization_id, options ) }.not_to raise_error
      conversation.id.should_not be_nil
      conversation.to_number.should == number
      conversation.from_number.should_not be_nil
    end
  end

end
