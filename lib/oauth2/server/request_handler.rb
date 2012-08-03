module OAuth2
  module Server
    class RequestHandler

      attr_reader :request, :client

      def self.from_request_params(params, config=nil)
        unless params.is_a? Hash
          raise "Request params must be a hash not #{params.class.name}"
        end
        req = OAuth2::Request(params)
        return new(req, config)
      end

      def initialize(request, config=nil)
        unless request.is_a? OAuth2::Server::Request
          raise "OAuth2::Server::Request expected but got #{request.class.name}"
        end
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

        unless @request.response_type?(:code)
          raise OAuth2Error::UnsupportedResponseType, "response_type: #{@response_type} is not supported"
        end

        verify_client_id

        generate_authorization_code
      end

      def fetch_access_token(user=nil, opts={})
        # {
        #   :access_token => "2YotnFZFEjr1zCsicMWpAA", 
        #   :token_type => "bearer",
        #   :expires_in => 3600,
        #   :refresh_token => "tGzv3JOkF0XG5Qx2TlKWIA",
        # }
        @request.validate

        verify_client_id

        if user.nil? && !@request.grant_type?(:refresh_token)
          raise "User must be provided"
        end

        unless (@request.grant_type || @request.response_type?(:token))
          # grant type validity is checked in the request object. Therefore if this
          # condition fails, the response_type is to blame
          raise OAuth2Error::InvalidRequest, "#response_type: {@response_type} is not valid for this request"
        end

        if @request.response_type?(:token)
          refresh_token = false
        end

        if @request.grant_type?(:authorization_code) 
          code = verify_authorization_code
        end

        if @request.grant_type?(:password)
          verify_user_credentials
        end

        if @request.grant_type?(:client_credentials)
          verify_client_credentials
        end

        if @request.grant_type?(:refresh_token) 
          token = @token_datastore.from_refresh_token(@request.refresh_token)
          unless token
            raise OAuth2::OAuth2Error::InvalidRequest, "invalid refresh token"
          end
          return token
        end  

        # run some user code
        yield if block_given?
        opts = { :scope => @scope }.merge(opts)
        token = @token_datastore.generate_user_token(user, @client, opts) 

        # deactivate used authorization code 
        code.deactivate! unless code.nil?

        token
      end

      def authorization_response
        # {
        #   :code => "2YotnFZFEjr1zCsicMWpAA",
        #   :state => "auth",
        # }
        response = {
          :code => fetch_authorization_code
        }
        response[:state] = @request.state unless @request.state.nil?
        response
      end

      def authorization_redirect_uri(allow=false) 
        # https://client.example.com/cb?code=SplxlOBeZQQYbYS6WxSbIA&state=xyz

        build_response_uri @request.redirect_uri, :query => authorization_response
      end

      def access_token_response(user, opts={})
        # http://example.com/cb#access_token=2YotnFZFEjr1zCsicMWpAA&state=xyz&token_type=example&expires_in=3600
        build_response_uri @request.redirect_uri, :fragment => fetch_access_token(user, opts).to_hsh
      end

      def error_response(oauth2_error)
        build_response_uri @request.redirect_uri, :query => oauth2_error.to_hsh
      end

    private

      # convenience method to build response URI  
      def build_response_uri(redirect_uri, opts={})
        query= opts[:query]
        fragment= opts[:fragment]
        # raise "Hash expected but got: #{query.inspect} and #{fragment.inspect}" unless (query.is_a?(Hash) && fragment.is_a?(Hash))
        uri = Addressable::URI.parse redirect_uri
        temp_query = uri.query_values || {}
        temp_frag = uri.fragment || nil
        uri.query_values = temp_query.merge(query) unless query.nil?
        uri.fragment = Addressable::URI.form_encode(fragment) unless fragment.nil?
        uri.to_s
      end

      def verify_client_id
        @client = @client_datastore.find_client_with_id(@request.client_id)
        return @client unless @client.nil?
        raise OAuth2::OAuth2Error::InvalidClient, "unknown client"
      end

      def verify_user_credentials
        authenticated = @user_datastore.authenticate request.username, request.password
        return true if authenticated
        raise OAuth2::OAuth2Error::AccessDenied, "user authentication failed"
      end

      def verify_client_credentials
        client = verify_client_id
        return true if client.verify_secret @request.client_secret
        raise OAuth2::OAuth2Error::InvalidClient, "client authentication failed"
      end

      def verify_authorization_code
        auth_code = @code_datastore.verify_authorization_code @request.client_id, @request.code, @request.redirect_uri
        if auth_code.nil? || auth_code.expired? || auth_code.deactivated?
          raise OAuth2::OAuth2Error::InvalidGrant, "invalid authorization code"
        end
        auth_code
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
