require 'addressable/uri'

module OAuth2Provider
  class Request

    RESPONSE_TYPES = [ :code, :token ]
    GRANT_TYPES    = [ :authorization_code, :password, :client_credentials, :refresh_token ]

    attr_reader :response_type, :grant_type, :client_id, :client_secret, :state, :scope, 
                :errors, :username, :password, :code, :refresh_token, :redirect_uri
    
    attr_accessor :validated

    def initialize(opts={})
      @client_id     = opts[:client_id]
      @client_secret = opts[:client_secret]
      @redirect_uri  = opts[:redirect_uri]
      @response_type = opts[:response_type]
      @grant_type    = opts[:grant_type]
      @state         = opts[:state]
      @scope         = opts[:scope]
      @code          = opts[:code]
      @username      = opts[:username]
      @password      = opts[:password]
      @refresh_token = opts[:refresh_token]
      @errors        = {}
      @validated     = nil
    end

    def valid?
      # REQUIRED: Check that client_id is valid
      validate_client_id!

      # OPTIONAL: Check the provided redirect URI is valid
      validate_redirect_uri!

      # REQUIRED: Either response_type or grant_type  
      unless (@response_type || @grant_type)
        raise Error::InvalidRequest, "response_type or grant_type is required"
      end

      if @response_type
        validate_response_type!
      else
        validate_grant_type!
      end
    end

    def validate_response_type!
      if @response_type.nil?
        raise Error::InvalidRequest, "response_type required"
      end
      if !RESPONSE_TYPES.include?(@response_type.to_sym)
        raise Error::UnsupportedResponseType, "unsupported response_type"
      end
      true
    end

    def validate_grant_type!
      if @grant_type.nil?
        raise Error::InvalidRequest, "grant_type required"
      end
      if !GRANT_TYPES.include?(@grant_type.to_sym)
        raise Error::UnsupportedGrantType, "unsupported grant_type"
      end
      true 
    end

    def validate_client_id!
      if @client_id.nil? || @client_id.empty?
        raise Error::InvalidRequest, "client_id is required"
      end
    end

    def validate_redirect_uri!
      return if (@redirect_uri.nil? || @redirect_uri.empty?)
      
      @errors[:redirect_uri] = []
      uri = Addressable::URI.parse(@redirect_uri)

      unless ["https", "http"].include? uri.scheme 
          @errors[:redirect_uri] << "unsupported uri scheme"
      end

      unless uri.fragment.nil?
          @errors[:redirect_uri] << "uri may not include fragment"
      end

      if @errors[:redirect_uri].any?
        raise Error::InvalidRequest, @errors[:redirect_uri].join(", ")
      end

      @redirect_uri 
    end
  end
end