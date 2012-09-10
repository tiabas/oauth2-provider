require 'net/http'

module OAuth2
  module Client
    class Client

      attr_accessor :client_id, :client_secret, :hostname, :authorize_path
                    :token_path, :scheme, :raise_errors, :http_client

      def initialize(client_id, client_secret, scheme, host, opts={})
        @client_id = client_id
        @client_secret = client_secret
        @scheme = scheme
        @host = host
        @authorize_path = opts[:authorize_path] || '/oauth/authorize'
        @token_path = opts[:token_path] || '/oauth/token'
        @raise_errors = opts[:raise_errors] || true
        @http_client = opts[:http_client] || OAuth2::Client::Connection
      end

      def build_connection()
        @http_client.new(@scheme, @host)
      end

      def implicit_grant(response_type, opts={})
        Request::Implicit.new(self, response_type, opts)
      end

      def authorization_code(code, opts={})
        Request::AuthorizationCode.new(self, code, opts)
      end

      def refresh_token(refresh_token, opts={})
        Request::RefreshToken.new(self, refresh_token, opts)
      end

      def client_credentials(opts={})
        Request::ClientCredentials.new(self, opts)
      end

      def password(username, password, opts={})
        Request::Password.new(self, username, password, opts)
      end
    end
  end
end