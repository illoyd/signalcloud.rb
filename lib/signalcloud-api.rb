require "signalcloud-api/version"

module SignalCloud

  class Appliance < ::APISmith::Smash
  
    property :id,                       transformer: :to_i
    property :phone_directory_id,       transformer: :to_i

    property :label
    property :description
    property :primary

    property :webhook_uri
    property :seconds_to_live

    property :question
    property :expected_confirmed_answer
    property :expected_denied_answer
    property :confirmed_reply
    property :denied_reply
    property :failed_reply
    property :expired_reply

    property :created_at,               transformer: lambda { |v| DateTime.parse(v) rescue nil }
    property :updated_at,               transformer: lambda { |v| DateTime.parse(v) rescue nil }
  end
  
  class Ticket < ::APISmith::Smash
    property :id,                   transformer: :to_i
    property :appliance_id,         transformer: :to_i
    property :to_number
    property :from_number
    
    property :status
    property :status_text

    property :challenge_status
    property :challenge_status_text

    property :reply_status
    property :reply_status_text

    property :webhook_uri

    property :question
    property :confirmed_reply
    property :denied_reply
    property :expired_reply
    property :failed_reply

    property :created_at,           transformer: lambda { |v| DateTime.parse(v) rescue nil }
    property :updated_at,           transformer: lambda { |v| DateTime.parse(v) rescue nil }
    property :expires_at,           transformer: lambda { |v| DateTime.parse(v) rescue nil }
    property :challenge_sent_at,    transformer: lambda { |v| DateTime.parse(v) rescue nil }
    property :response_received_at, transformer: lambda { |v| DateTime.parse(v) rescue nil }
    property :reply_received_at,    transformer: lambda { |v| DateTime.parse(v) rescue nil }
  end
  
  class SignalCloudError < StandardError; end

  class Client
    include ::APISmith::Client
    #base_uri "http://app.signalcloudapp.com/"
    base_uri "http://localhost:5000/"
    # endpoint "api/v1"
    
    attr_reader :username, :password

    def initialize( username, password )
      @username = username
      @password = password
      add_request_options!( basic_auth: {username: self.username, password: self.password} )
    end
    
    def appliances()
      get 'appliances.json', response_container: %w( appliances ), transform: SignalCloud::Appliance
    end

    def appliance( id )
      get "appliances/#{id}.json", response_container: %w( appliance ), transform: SignalCloud::Appliance
    end
    
    def tickets()
      get "tickets.json", response_container: %w( tickets ), transform: SignalCloud::Ticket
    end

    def open_tickets( id )
      get "appliances/#{id}/tickets/open.json", response_container: %w( tickets ), transform: SignalCloud::Ticket
    end
    
    def ticket( id )
      get "tickets/#{id}.json", response_container: %w( ticket ), transform: SignalCloud::Ticket
    end
  
    def open_ticket( params={} )
      post 'appliances/4/tickets.json', extra_query: { ticket: params }, response_container: %w( ticket ), transform: SignalCloud::Ticket
    end
    
    private

    def base_query_options
      { :format => 'json' }
    end
    
#     def check_response_errors(response)
#       if response.first.is_a?(Hash) and (error = response.first['error'])
#         raise SignalCloudError.new(error)
#       end
#     end
  
  end

end
