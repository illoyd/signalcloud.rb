require "signalcloud/version"
require 'api_smith'

require 'signalcloud/stencil'
require 'signalcloud/message'
require 'signalcloud/conversation'

module SignalCloud

  class SignalCloudError < StandardError; end

  class Client
    include ::APISmith::Client
    base_uri "https://app.signalcloudapp.com/"
    
    attr_reader :username, :password

    def initialize( username=nil, password=nil )
      @username = username || ENV['SIGNALCLOUD_USERNAME']
      @password = password || ENV['SIGNALCLOUD_PASSWORD']
      
      raise SignalCloudError.new( 'Username or Password was nil. Define your credentials either through parameters or through the SIGNALCLOUD_USERNAME and SIGNALCLOUD_PASSWORD environment variables.' ) if ( @username.nil? or @password.nil? )
      
      add_request_options!( basic_auth: {username: self.username, password: self.password} )
    end
    
    def stencils( options={} )
      get 'stencils.json', extra_query: options, response_container: %w( stencils ), transform: SignalCloud::Stencil
    end

    def stencil( id )
      get "stencils/#{id}.json", response_container: %w( stencil ), transform: SignalCloud::Stencil
    end
    
    def conversations( options={} )
      get "conversations.json", extra_query: options, response_container: %w( tickets ), transform: SignalCloud::Conversation
    end

    def conversation( id )
      get "conversations/#{id}.json", response_container: %w( ticket ), transform: SignalCloud::Conversation
    end
  
#     def open_tickets( id )
#       get "stencils/#{id}/tickets/open.json", response_container: %w( tickets ), transform: SignalCloud::Ticket
#     end
    
    def start_conversation( params={} )
      ticket_uri = 'conversations.json'
      ticket_uri = "stencils/#{params[:stencil_id]}/#{ticket_uri}" if params.include? :stencil_id
      post ticket_uri, extra_query: { ticket: params }, response_container: %w( ticket ), transform: SignalCloud::Ticket
    end
    
    private

    def base_query_options
      { :format => 'json' }
    end
    
    def check_response_errors(response)
      if response.first.is_a?(Hash) and (error = response.first['error'])
        raise SignalCloudError.new(error)
      end
    end
  
  end

end
