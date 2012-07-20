require 'addressable/uri'

module OAuth2
  module Server
    class AbstractRequest

      RESPONSE_TYPES = [ :code, :token ]
      GRANT_TYPES = [ :authorization_code, :password, :client_credentials :refresh_token ]

      attr_reader :response_type, :grant_type, :client_id, :client_secret, :state, :scope, 
                  :errors

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
        @errors        = {}
        @validated     = nil
      end

      def client_application
        @client_application || validate_client_id
      end

      def client_valid?
        !!client_application
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

      def response_type_code?
        @response_type.to_sym == :code
      end

      def response_type_token?
        @response_type.to_sym == :token
      end

      def redirect_uri
        @redirect_uri.nil? client_application.redirect_uri : validate_redirect_uri
      end
      
    private

      def validate
        # check if we already ran validation
        return unless @validated.nil?

        # REQUIRED: Check that client_id is valid
        validate_client_id

        # REQUIRED: Either response_type or grant_type  
        if response_type.nil? && grant_type.nil?
          raise OAuth2Error::InvalidRequest, "Missing parameters: response_type or grant_type"
        end

        # validate response_type if given
        validate_response_type unless @response_type.nil?

        # validate grant_type if given
        validate_grant_type unless @grant_type.nil?

        # validate redirect uri if given grant_type is authorization_code or response_type is token
        if @response_type.to_sym == :token || @grant_type.to_sym == :authorization_code
          validate_redirect_uri
        end

        # validate code if grant_type is client_credentials
        if @grant_type.to_sym == :client_credentials
          validate_client_credentials
        end

        # validate code if grant_type is authorization_code
        if @grant_type.to_sym == :authorization_code
          validate_authorization_code
        end

        # validate user credentials if grant_type is password
        if @grant_type.to_sym == :password
          validate_user_credentials
        end

        # validate user credentials if grant_type is password
        if @grant_type.to_sym == :refresh_token
          validate_refresh_token
        end
        
        # cache validation result
        @validated = true
      end

      def validate_authorization_code
        if @code.nil?
          raise OAuth2Error::InvalidRequest, "Missing parameters: code"
        end
        unless verify_authorization_code
          raise OAuth2Error::UnauthorizedClient, "Authorization code provided did not match client"
        end
        @code
      end

      def validate_client_id
        if @client_id.nil?
          raise OAuth2Error::InvalidRequest, "Missing parameters: client_id"
        end
        @client_application = OauthClientApplication.verify_id client_id
        return @client_application unless @client_application.nil?
        raise OAuth2Error::InvalidClient
      end

      def validate_client_credentials
        if @client_id.nil? && @client_secret.nil?
          @errors[:client] = []
          @errors[:client] << "client_id" if @client_id.nil?
          @errors[:client] << "client_secret" if @client_secret.nil?
          raise OAuth2Error::InvalidRequest, "Missing parameters: #{@errors[:client].join(", ")}"
        end
        authenticated = OauthClientApplication.authenticate @client_id, @client_secret
        @errors[:client] = "Unauthorized Client"
        raise OAuth2Error::UnauthorizedClient, @errors[:client] 
      end

      def validate_user_credentials
        if @username.nil? || @password.nil?
          @errors[:user_credentials] = []
          @errors[:user_credentials] << "username" if @username.nil?
          @errors[:user_credentials] << "password" if @password.nil?
          raise OAuth2Error::InvalidRequest, "Missing parameters: #{@errors[:user_credentials].join(", ")}"
        end
        user = authenticate_user_credentials username, password
        return user unless user.nil?
        @errors[:credentials] = "Invalid username and/or password"
        raise OAuth2Error::AccessDenied, @errors[:credentials]
      end

      def validate_response_type
        return RESPONSE_TYPES.include? @response_type.to_sym
        @errors[:response_type] = "Invalid response type"
        raise OAuth2Error::UnsupportedResponseType
      end

      def validate_grant_type
        return GRANT_TYPES.include? @grant_type.to_sym
        @errors[:grant_type] = "Unsupported grant type"
        raise OAuth2Error::UnsupportedGrantType
      end

      def validate_refresh_token
        if @refresh_token.nil?
          raise OAuth2Error::InvalidRequest, "Missing parameters: refresh_token"
        end
        token = verify_refresh_token
        return true unless token.nil?
        raise OAuth2Error::InvalidRequest, "Invalid refresh token" 
      end

      def validate_scope
        verify_request_scope
        @errors[:scope] = "InvalidScope"
        raise OAuth2Error::InvalidScope, "FIX ME!!!!!!"
      end

      def validate_redirect_uri
        return if @redirect_uri.nil?
        
        errors[:redirect_uri] = []

        uri = Addressable::URI.parse(@redirect_uri)
        unless uri.scheme == "https" 
            errors[:redirect_uri] << "URI scheme is unsupported"
        end
        unless uri.fragment.nil?
            errors[:redirect_uri] << "URI should not include URI fragment"
        end
        unless uri.query.nil?
            errors[:redirect_uri] << "URI should not include query string"
        end
        if errors[:redirect_uri].any?
          raise OAuth2Error::InvalidRequest, errors[:redirect_uri].join(", ")
        end

        unless client_application.redirect_uri == @redirect_uri
          raise OAuth2Error::InvalidRequest, "Redirect URI does not match the one on record"
        end
        @redirect_uri 
      end

      def authenticate_user_credentials
        raise NotImplementedError.new("You must implement #{name}.")
      end

      def authenticate_client_credentials
        raise NotImplementedError.new("You must implement #{name}.")
      end

      def verify_client_id
        raise NotImplementedError.new("You must implement #{name}.")
      end

      def verify_request_scope
        raise NotImplementedError.new("You must implement #{name}.")
      end

      def verify_authorization_code
        raise NotImplementedError.new("You must implement #{name}.")
      end
    end
  end
end