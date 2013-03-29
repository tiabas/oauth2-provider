require 'addressable/uri'

module OAuth2
  module Provider
    class Request

      RESPONSE_TYPES = [ :code, :token ]
      GRANT_TYPES = [ :authorization_code, :password, :client_credentials, :refresh_token ]

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

      def validate!
        # REQUIRED: Check that client_id is valid
        validate_client_id

        # REQUIRED: Either response_type or grant_type  
        unless (@response_type || @grant_type)
          raise OAuth2::Provider::Error::InvalidRequest, "response_type or grant_type is required"
        end

        # validate response_type if given
        if @response_type
          validate_response_type
          validate_redirect_uri
        else
          validate_grant_type
        end

      end

      def validate_client_id
        return true unless @client_id.nil?
        raise OAuth2::Provider::Error::InvalidRequest, "client_id required"
      end

      def validate_scope
        return if (@scope.nil? || @scope.strip.empty?)
        #TODO check scope
        @errors[:scope] = "invalid scope"
        raise OAuth2::Provider::Error::InvalidRequest, @errors[:scope]
      end

      def validate_redirect_uri
        return true if @redirect_uri.empty
        
        @errors[:redirect_uri] = []

        uri = Addressable::URI.parse(@redirect_uri)
        unless ["https", "http"].include? uri.scheme 
            @errors[:redirect_uri] << "unsupported uri scheme"
        end
        unless uri.fragment.nil?
            @errors[:redirect_uri] << "uri may not include fragment"
        end

        if @errors[:redirect_uri].any?
          raise OAuth2::Provider::Error::InvalidRequest, @errors[:redirect_uri].join(", ")
        end

        @redirect_uri 
      end

      def validate_response_type
        if @response_type.nil?
          raise OAuth2::Provider::Error::InvalidRequest, "response_type required"
        end
        if !RESPONSE_TYPES.include?(@response_type.to_sym)
          raise OAuth2::Provider::Error::UnsupportedResponseType, "response_type not supported"
        end
        true
      end

      def validate_grant_type
        if @grant_type.nil?
          raise OAuth2::Provider::Error::InvalidRequest, "grant_type required"
        end
        if !GRANT_TYPES.include?(@grant_type.to_sym)
          raise OAuth2::Provider::Error::UnsupportedGrantType, "grant_type not supported"
        end
        true 
      end
    end
  end
end
