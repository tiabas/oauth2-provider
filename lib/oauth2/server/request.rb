require 'addressable/uri'

# This class handles the OAuth2 token creation and exchange process

module OAuth2
  module Server
    class Request

      RESPONSE_TYPES = [ :code, :token ]
      GRANT_TYPES = [ :authorization_code, :password, :client_credentials, :refresh_token ]

      attr_reader :response_type, :grant_type, :client_id, :client_secret, :state, :scope, 
                  :errors, :username, :password, :code, :refresh_token, :redirect_uri
      
      attr_accessor :validated

      def self.from_http_request
      # create request from http headers
      end

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

      def grant_type_valid?
        !!validate_grant_type
      rescue OAuth2Error::InvalidRequest => e
        false
      end

      def response_type_valid?
        !!validate_response_type
      rescue OAuth2Error::InvalidRequest => e
        false
      end

      def redirect_uri_valid?
        !!validate_redirect_uri
      rescue OAuth2Error::InvalidRequest => e
        false
      end

      def grant_type?(value)
        return @grant_type && (@grant_type == value.to_s)
      end

      def response_type?(value)
        return @response_type && (@response_type == value.to_s)
      end

      def valid?
        validate
      end

      def validate
        # check if we already ran validation
        return @validated unless @validated.nil?

        @validated = false

        # REQUIRED: Check that client_id is valid
        validate_client_id

        # REQUIRED: Either response_type or grant_type  
        if @response_type.nil? && @grant_type.nil?
          raise OAuth2Error::InvalidRequest, "request parameters missing:: response_type or grant_type"
        end

        # validate response_type if given
        unless @response_type.nil?
          validate_response_type

          # validate redirect uri if grant_type is authorization_code or response_type is token
          validate_redirect_uri if @response_type.to_sym == :token || @response_type.to_sym == :code
        end

        # validate grant_type if given
        unless @grant_type.nil?
          validate_grant_type

          if @grant_type.to_sym == :client_credentials
          # validate code if grant_type is client_credentials
            validate_client_credentials
          elsif @grant_type.to_sym == :authorization_code
          # validate code if grant_type is authorization_code
            validate_authorization_code
          elsif @grant_type.to_sym == :password
          # validate user credentials if grant_type is password
            validate_user_credentials
          elsif @grant_type.to_sym == :refresh_token
          # validate user credentials if grant_type is password
            validate_refresh_token
          end
        end
        
        # cache validation result
        @validated = true
      end

    # private
    
      def validate_authorization_code
        return true unless code.nil?
        raise OAuth2Error::InvalidRequest, "request parameters missing:: code"
      end

      def validate_client_id
        return true unless @client_id.nil?
        raise OAuth2Error::InvalidRequest, "request parameters missing:: client_id"
      end

      def validate_client_credentials
        unless @client_id && @client_secret
          @errors[:client] = []
          @errors[:client] << "client_id" if @client_id.nil?
          @errors[:client] << "client_secret" if @client_secret.nil?
          raise OAuth2Error::InvalidRequest, "request parameters missing:: #{@errors[:client].join(", ")}"
        end
        true
      end

      def validate_user_credentials
        if @username.nil? || @password.nil?
          @errors[:user_credentials] = []
          @errors[:user_credentials] << "username" if @username.nil?
          @errors[:user_credentials] << "password" if @password.nil?
          raise OAuth2Error::InvalidRequest, "missing parameters: #{@errors[:user_credentials].join(", ")}"
        end
        true
      end

      def validate_response_type
        if @response_type.nil?
          raise OAuth2Error::InvalidRequest, "missing parameters: response_type"
        end
        return true if RESPONSE_TYPES.include? @response_type.to_sym
        raise OAuth2Error::UnsupportedResponseType
      end

      def validate_grant_type
        if @grant_type.nil?
          raise OAuth2Error::InvalidRequest, "missing parameters: grant_type"
        end
        return true if GRANT_TYPES.include? @grant_type.to_sym
        raise OAuth2Error::UnsupportedGrantType
      end

      def validate_refresh_token
        return true unless refresh_token.nil?
        raise OAuth2Error::InvalidRequest, "missing parameters: refresh_token"
      end

      def validate_scope
        verify_request_scope
        @errors[:scope] = "InvalidScope"
        raise OAuth2Error::InvalidScope, "FIX ME!!!!!!"
      end

      def validate_redirect_uri
        return true if @redirect_uri.nil?
        
        @errors[:redirect_uri] = []

        uri = Addressable::URI.parse(@redirect_uri)
        unless uri.scheme == "https" 
            @errors[:redirect_uri] << "URI scheme is unsupported"
        end
        unless uri.fragment.nil?
            @errors[:redirect_uri] << "URI should not include URI fragment"
        end
        unless uri.query.nil?
            @errors[:redirect_uri] << "URI should not include query string"
        end
        if @errors[:redirect_uri].any?
          raise OAuth2Error::InvalidRequest, @errors[:redirect_uri].join(", ")
        end

        @redirect_uri 
      end
    end
  end
end