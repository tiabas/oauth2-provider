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
          raise OAuth2::Provider::Error::InvalidRequest, "Response type or grant type is required"
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
        raise Provider::Error::InvalidRequest, "Client ID required"
      end

      def validate_scope
        return true if (@scope.nil? || @scope.strip.empty?)
        #TODO check if provided scope exists
        @errors[:scope] = "invalid scope"
        raise Provider::Error::InvalidRequest, @errors[:scope]
      end

      def validate_redirect_uri
        return true if (!@redirect_uri || @redirect_uri.empty?)
        
        uri = Addressable::URI.parse(@redirect_uri)
        unless ["https", "http"].include? uri.scheme 
          raise OAuth2::Provider::Error::InvalidRequest, "Unsupported uri scheme, #{uri.scheme}"
        end

        unless uri.fragment.nil?
          raise OAuth2::Provider::Error::InvalidRequest, "Redirect URI must not contain fragment"
        end

        @redirect_uri 
      end

      def validate_response_type
        if @response_type.nil?
          raise OAuth2::Provider::Error::InvalidRequest, "Response type required"
        end
        if !RESPONSE_TYPES.include?(@response_type.to_sym)
          raise OAuth2::Provider::Error::UnsupportedResponseType, "Response type not supported"
        end
        true
      end

      def validate_grant_type
        if @grant_type.nil?
          raise OAuth2::Provider::Error::InvalidRequest, "Grant type required"
        end
        if !GRANT_TYPES.include?(@grant_type.to_sym)
          raise OAuth2::Provider::Error::UnsupportedGrantType, "Grant type not supported"
        end
        true 
      end
    end
  end
end
