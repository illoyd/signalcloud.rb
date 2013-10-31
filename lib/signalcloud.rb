require "signalcloud/version"
require 'api_smith'

require 'signalcloud/organization'
require 'signalcloud/stencil'
require 'signalcloud/message'
require 'signalcloud/conversation'

module SignalCloud

  class SignalCloudError < StandardError; end
  class InvalidCredentialError < SignalCloudError; end
  class ObjectNotFoundError < SignalCloudError; end

  class Client
    include ::APISmith::Client
    base_uri "https://us.signalcloudapp.com/"
    
    attr_reader :username, :password

    def initialize( username=nil, password=nil, options={} )
      @username = username || ENV['SIGNALCLOUD_USERNAME']
      @password = password || ENV['SIGNALCLOUD_PASSWORD']
      
      raise SignalCloudError.new( 'Username or Password was nil. Define your credentials either through parameters or through the SIGNALCLOUD_USERNAME and SIGNALCLOUD_PASSWORD environment variables.' ) if ( @username.nil? or @password.nil? )
      
      options.each do |key,value|
        send(key, value) if respond_to? key
        self.class.send(key, value) if self.class.respond_to? key
      end
      
      add_request_options!( basic_auth: {username: self.username, password: self.password} )
    end
    
    def organizations( options={} )
      get "organizations.json", extra_query: options, response_container: %w( organizations ), transform: SignalCloud::Organization
    end

    def organization( organization_id, options={} )
      get "organizations/#{organization_id}.json", extra_query: options, response_container: %w( organization ), transform: SignalCloud::Organization
    end

    def stencils( organization_id, options={} )
      get "organizations/#{organization_id}/stencils.json", extra_query: options, response_container: %w( stencils ), transform: SignalCloud::Stencil
    end

    def stencil( organization_id, id )
      get "organizations/#{organization_id}/stencils/#{id}.json", response_container: %w( stencil ), transform: SignalCloud::Stencil
    end
    
    def conversations( organization_id, options={} )
      get "organizations/#{organization_id}/conversations.json", extra_query: options, response_container: %w( conversations ), transform: SignalCloud::Conversation
    end

    def conversation( organization_id, id )
      get "organizations/#{organization_id}/conversations/#{id}.json", response_container: %w( conversation ), transform: SignalCloud::Conversation
    end
  
#     def open_tickets( id )
#       get "stencils/#{id}/tickets/open.json", response_container: %w( tickets ), transform: SignalCloud::Ticket
#     end
    
    def start_conversation( organization_id, params={} )
      conversation_uri = 'conversations.json'
      conversation_uri = "stencils/#{params[:stencil_id]}/#{conversation_uri}" if params.include? :stencil_id
      conversation_uri = "organizations/#{organization_id}/#{conversation_uri}"
      post conversation_uri, extra_query: { conversation: params }, response_container: %w( conversation ), transform: SignalCloud::Conversation
    end
    
    private

    def base_query_options
      { :format => 'json' }
    end
    
    def check_response_errors(response)
      # Raise specific errors
      raise InvalidCredentialError.new(response['error']) if response.code == 401
      raise ObjectNotFoundError if response.code == 404

      # Raise a general error
      if response.is_a?(Hash) and (error = response['error'] || response['errors'])
        raise SignalCloudError.new(error)
      end
    end
  
  end

end
