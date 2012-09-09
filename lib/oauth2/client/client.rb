module OAuth2
  module Client
    class Client

      attr_accessor :client_id, :client_secret, :hostname, :authorize_path
                    :token_path, :use_ssl, :raise_errors, :http_client

      def initialize(client_id, client_secret, hostname, opts={})
        @client_id = client_id
        @client_secret = client_secret
        @hostname = hostname
        @authorize_path = opts[:authorize_path] || '/oauth/authorize'
        @token_path = opts[:token_path] || '/oauth/token'
        @request_method = opts[:request_method] || 'post'
        @use_ssl = opts[:ssl] || true
        @raise_errors = opts[:raise_errors] || true
        @http_client = opts[:http_client] || OAuth2::Client::BasicHTTPClient
      end

      def build_connection
        scheme = use_ssl ? 'https' : 'http'
        @connection = @http_client.new(scheme, @hostname)
      end

      def implicit_grant(response_type, opts={})
        Request::Implicit.new(@connection, @client_id, @client_secret, response_type, opts)
      end

      def authorization_code(code, opts={})
        Request::AuthorizationCode.new(@connection, @client_id, @client_secret, code, opts)
      end

      def refresh_token(refresh_token, opts={})
        Request::RefreshToken.new(@connection, @client_id, @client_secret, refresh_token, opts)
      end

      def client_credentials(opts={})
        Request::ClientCredentials.new(@connection, @client_id, @client_secret, opts)
      end

      def password(username, password, opts={})
        Request::Password.new(@connection, @client_id, @client_secret, username, password, opts)
      end
    end
  end
end