module OAuth2
  module Server
    class RequestHandler

      attr_reader :request, :client
      
      def initialize(request, config=nil)
        @request = request
        @user_datastore = config[:user_datastore]
        @client_datastore = config[:client_datastore]
        @token_datastore = config[:token_datastore]
        @code_datastore = config[:code_datastore]
      end

      def client_application
        @client || verify_client_id
      end

      def fetch_authorization_code
        @request.validate
        
        unless @request.response_type_code?
          raise OAuth2Error::UnsupportedResponseType, "The response type, #{@response_type}, is not valid for this request"
        end
        
        verify_client_id
        
        generate_authorization_code
      end

      def fetch_access_token(user, refreshable=false, expires_in=3600, token_type='bearer')
        # {
        #   :access_token => "2YotnFZFEjr1zCsicMWpAA", 
        #   :token_type => "bearer",
        #   :expires_in => 3600,
        #   :refresh_token => "tGzv3JOkF0XG5Qx2TlKWIA",
        # }
        @request.validate
        
        verify_client_id
        
        code = verify_authorization_code

        unless (@request.grant_type || @request.response_type_token?)
          raise OAuth2Error::UnsupportedResponseType, "The response type provided is not valid for this request"
        end
        
        if @request.grant_type == :authorization_code && !verify_authorization_code
          raise OAuth2Error::UnauthorizedClient
        end

        if @request.grant_type == :password && !verify_user_credentials
          raise OAuth2Error::AccessDenied
        end

        if @request.grant_type == :client_credentials && !verify_client_credentials
          raise OAuth2Error::UnauthorizedClient
        end

        if @request.grant_type == :refresh_token && !verify_refresh_token
          raise OAuth2Error::UnauthorizedClient
        end      

        # yield if we wish to perform anymore security checks
        yield 

        refresh_token = @request.grant_type?(:client_credentials) ? false : refresh_token 

        token = access_token_datastore.create_token(user, @client_app, refreshable) 
        
        code.deactivate!

        token
      end

      def authorization_redirect_uri(allow=false) 
        # https://client.example.com/cb?code=SplxlOBeZQQYbYS6WxSbIA&state=xyz
        build_response_uri @request.redirect_uri, authorization_response
      end

      def access_token_redirect_uri
        # http://example.com/cb#access_token=2YotnFZFEjr1zCsicMWpAA&state=xyz&token_type=example&expires_in=3600
        build_response_uri @request.redirect_uri, nil, fetch_access_token.to_hsh
      end

    private
      
      # convenience method to build response URI  
      def build_response_uri(redirect_uri, query_params=nil, fragment_params=nil)
        uri = Addressable::URI.parse redirect_uri
        uri.query_values = Addressable::URI.form_encode query_params unless query_params.nil?
        uri.fragment = Addressable::URI.form_encode fragment_params unless fragment_params.nil?
        return uri
      end

      def authorization_response
        # {
        #   :code => "2YotnFZFEjr1zCsicMWpAA", 
        #   :state => "auth",
        # }
        response = { 
          :code => generate_authorization_code
        }
        response[:state] = @request.state unless @request.state.nil?
        response 
      end

      def verify_client_id
        @client = @client_datastore.find_client_with_id(@request.client_id)
        return @client unless @client.nil?
        raise OAuth2::OAuth2Error::InvalidClient, "Unknown client"
      end

      def verify_user_credentials
        authenticated = @user_datastore.authenticate request.username, request.password
        return true if authenticated
        raise OAuth2::OAuth2Error::InvalidClient, "Client authentication failed"
      end

      def verify_client_credentials
        client = verify_client_id
        return true if client.verify_secret @request.client_secret
        raise OAuth2::OAuth2Error::InvalidClient, "Client authentication failed"
      end

      def verify_authorization_code
        code = @code_datastore.verify_authorization_code @request.client_id, @request.code, @request.redirect_uri
        if code.expired? || inactive?
          raise OAuth2::OAuth2Error::Error, "authorization code expired"
        end
        code
      end

      def verify_request_scope
        raise NotImplementedError
      end

      def generate_authorization_code
        @code_datastore.generate_authorization_code @request.client_id, @request.redirect_uri
      end
    end
  end
end
