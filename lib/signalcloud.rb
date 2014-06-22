require "signalcloud/version"
require 'api_smith'

require 'signalcloud/time_transformer'
require 'signalcloud/organization'
require 'signalcloud/stencil'
require 'signalcloud/message'
require 'signalcloud/conversation'

module SignalCloud

  ##
  # US service URI.
  US_BASE_URI = 'https://us.signalcloudapp.com'
  
  ##
  # EU service URI.
  EU_BASE_URI = 'https://eu.signalcloudapp.com'
  
  ##
  # The default service URI; currently defaults to the EU service.
  DEFAULT_BASE_URI = EU_BASE_URI

  ##
  # Standard SignalCloud error. All errors produced by the SignalCloud library or service will be raised as this Error class.
  class SignalCloudError < StandardError; end
  class InvalidCredentialError < SignalCloudError; end
  class ObjectNotFoundError < SignalCloudError; end

  class Client
    include ::APISmith::Client
    
    attr_reader :username, :password

    def initialize( username=nil, password=nil, options={} )
      @username = username || ENV['SIGNALCLOUD_USERNAME']
      @password = password || ENV['SIGNALCLOUD_PASSWORD']
      
      raise SignalCloudError.new( 'Username or Password was nil. Define your credentials either through parameters or through the SIGNALCLOUD_USERNAME and SIGNALCLOUD_PASSWORD environment variables.' ) if ( @username.nil? or @password.nil? )

      # Assign base URI by parameters      
      self.class.base_uri self.class.pick_base_uri

      options.each do |key,value|
        self.class.send(key, value) if self.class.respond_to? key
        send(key, value) if respond_to? key
      end
      
      #self.basic_auth(username, password)
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
    
    def start_conversation( organization_id, params={} )
      conversation_uri = 'conversations.json'
      conversation_uri = "stencils/#{params[:stencil_id]}/#{conversation_uri}" if params.include? :stencil_id
      conversation_uri = "organizations/#{organization_id}/#{conversation_uri}"
      post conversation_uri, extra_query: { conversation: params }, response_container: %w( conversation ), transform: SignalCloud::Conversation
    end
    
    ##
    # Pick the appropriate base URI to use based on environment variables.
    # Uses the +SIGNALCLOUD_URI+ environment variable to select the URI.
    # Accepts one either a fully qualified URI, or country short-cuts as follows:
    # * +EU+ for the European version.
    # * +US+ for the United States version.
    # If the parameter is blank or is not one of the country codes, will default to the EU version.
    def self.pick_base_uri(uri = nil)
      case (uri || ENV['SIGNALCLOUD_URI']).to_s.strip.downcase
      when 'eu'
        EU_BASE_URI
      when 'us'
        US_BASE_URI
      when nil, ''
        DEFAULT_BASE_URI
      else
        uri
      end
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
