module OAuth2
  module Server
    class RequestHandler

      attr_reader :request
      
      def intialize(request)
        # OAuth2::Server::Request.new(request)
        @request = request
      end

      def client_application
        @client_application || verify_client_id
      end

      def fetch_authorization_code
        # run request validations
        # make sure response_type is code
        # get user approval
        request.validate
        unless request.response_type_code?
          raise OAuth2Error::UnsupportedResponseType, "The response type, #{@response_type}, is not valid for this request"
        end
        generate_authorization_code
      end

      def fetch_access_token
        # {
        #   :access_token => "2YotnFZFEjr1zCsicMWpAA", 
        #   :token_type => "bearer",
        #   :expires_in => 3600,
        #   :refresh_token => "tGzv3JOkF0XG5Qx2TlKWIA",
        # }
        request.validate
        
        unless (request.grant_type || request.response_type_token?)
          raise OAuth2Error::UnsupportedResponseType, "The response type provided is not valid for this request"
        end
        
        if request.grant_type == :authorization_code && !verify_authorization_code
          raise OAuth2Error::UnauthorizedClient

        if request.grant_type == :password && !verify_user_credentials
          raise OAuth2Error::AccessDenied
        end

        if request.grant_type == :client_credentials && !verify_client_credentials
          raise OAuth2Error::UnauthorizedClient
        end

        if request.grant_type == :refresh_token && !verify_refresh_token
          raise OAuth2Error::UnauthorizedClient
        end      

        token = generate_access_token 
        
        # TODO: invalidate authorization code

        token
      end

      def authorization_redirect_uri(allow=false) 
        # https://client.example.com/cb?code=SplxlOBeZQQYbYS6WxSbIA&state=xyz
        build_response_uri request.redirect_uri, authorization_response
      end

      def access_token_redirect_uri
        # http://example.com/cb#access_token=2YotnFZFEjr1zCsicMWpAA&state=xyz&token_type=example&expires_in=3600
        build_response_uri request.redirect_uri, nil, fetch_access_token.to_hsh
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
          :code => fetch_authorization_code
        }
        response[:state] = request.state unless request.state.nil?
        response 
      end

      def verify_client_id
        raise NotImplementedError
      end

      def verify_client_credentials
        client_application.authenticate client_secret
      end

      def verify_user_credentials
        raise NotImplementedError
      end

      def verify_request_scope
        raise NotImplementedError
      end

      def verify_authorization_code
        raise NotImplementedError
      end

      def generate_authorization_code
        # OAuth2::AuthorizationCode::new_code_for_client
        raise NotImplementedError.new("You must implement #{name}.") 
      end

      def generate_access_token
        # OAuth2::AccessToken::new_token_for_client_and_user(request.client, current_user)
        raise NotImplementedError.new("You must implement #{name}.")
      end
    end
  end
end
