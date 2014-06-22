require "signalcloud/version"
require 'api_smith'

require 'signalcloud/time_transformer'
require 'signalcloud/organization'
require 'signalcloud/stencil'
require 'signalcloud/message'
require 'signalcloud/conversation'

##
# A helper library for working with the SignalCloud service.
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
  
  ##
  # A SignalCloudError raised whenever the service cannot authenticate the provided user credentials.
  class InvalidCredentialError < SignalCloudError; end
  
  ##
  # A SignalCloudError rasied whenever a requested object could not be found.
  class ObjectNotFoundError < SignalCloudError; end

  ##
  # The primary Client for using the SignalCloud service. Either sub-class this object to make your own client or use it directly.
  #
  # The Client uses several environment variables to automagically set defaults.
  # [SIGNALCLOUD_URI] The service URI. May be either a fully qualified URI, or US or EU to use the respective region-specific service. Defaults to the EU service URI.
  # [SIGNALCLOUD_USERNAME] A valid SignalCloud username
  # [SIGNALCLOUD_PASSWORD] A valid SignalCloud password
  class Client
    include ::APISmith::Client
    
    ##
    # The BASIC AUTH username for the SignalCloud service.
    attr_reader :username

    ##
    # The BASIC AUTH password for the SignalCloud service.
    attr_reader :password

    ##
    # Create a new Client
    # [username] A SignalCloud username, or nil to use the SIGNALCLOUD_USERNAME environment variable
    # [password] A SignalCloud password, or nil to use the SIGNALCLOUD_PASSWORD environment variable
    # [options]  A Hash of options to pass to the Client. Keys may be any method which the Client understands, while the value must be in a format the method can understand.
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
    
    ##
    # Request all organizations available to this user account.
    # [options] A Hash of key-value pairs to be submitted with the request as a query (i.e. after a ? in the request URI).
    # Returns an Array of Organization objects.
    def organizations( options={} )
      get "organizations.json", extra_query: options, response_container: %w( organizations ), transform: SignalCloud::Organization
    end

    ##
    # Request a specific organization by unique ID.
    # [organization_id] The ID of the holding Organization
    # [options]         A Hash of key-value pairs to be submitted with the request as a query (i.e. after a ? in the request URI).
    # Returns an Organization object.
    def organization( organization_id, options={} )
      get "organizations/#{organization_id}.json", extra_query: options, response_container: %w( organization ), transform: SignalCloud::Organization
    end

    ##
    # Request all stencils available to this user account and the specified organization.
    # [organization_id] The ID of the holding Organization
    # [options]         A Hash of key-value pairs to be submitted with the request as a query (i.e. after a ? in the request URI).
    # Returns an Array of Stencil objects.
    def stencils( organization_id, options={} )
      get "organizations/#{organization_id}/stencils.json", extra_query: options, response_container: %w( stencils ), transform: SignalCloud::Stencil
    end

    ##
    # Request a specific Stencil by Organization and Stencil IDs.
    # [organization_id] The ID of the holding Organization
    # [stencil_id]      The ID of the requested Stencil
    # [options]         A Hash of key-value pairs to be submitted with the request as a query (i.e. after a ? in the request URI).
    # Returns an Organization object.
    def stencil( organization_id, stencil_id, options={} )
      get "organizations/#{organization_id}/stencils/#{stencil_id}.json", extra_query: options, response_container: %w( stencil ), transform: SignalCloud::Stencil
    end
    
    ##
    # Request all Stencils available to this user account and the specified organization.
    # [organization_id] The ID of the holding Organization
    # [options]         A Hash of key-value pairs to be submitted with the request as a query (i.e. after a ? in the request URI).
    # Returns an Array of Conversation objects.
    def conversations( organization_id, options={} )
      get "organizations/#{organization_id}/conversations.json", extra_query: options, response_container: %w( conversations ), transform: SignalCloud::Conversation
    end

    ##
    # Request a specific Conversation by Organization and Conversation IDs.
    # [organization_id] The ID of the holding Organization
    # [conversation_id] The ID of the requested Conversation
    # [options]         A Hash of key-value pairs to be submitted with the request as a query (i.e. after a ? in the request URI).
    # Returns a Conversation object.
    def conversation( organization_id, conversation_id, options={} )
      get "organizations/#{organization_id}/conversations/#{conversation_id}.json", extra_query: options, response_container: %w( conversation ), transform: SignalCloud::Conversation
    end
    
    ##
    # Start a new Conversation for the given Organization.
    # [organization_id] The ID of the holding Organization
    # [options]         A Hash of key-value pairs to be submitted with the request. Please see http://www.signalcloudapp.com/dev for details on accepted parameters.
    # Returns a Conversation object.
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
    
    ##
    # Always make requests as JSON.
    def base_query_options
      { :format => 'json' }
    end
    
    ##
    # Peform error checking on responses.
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
