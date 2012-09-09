module OAuth2
  module Client
    module Request
      class AuthorizationCode
        def initialize(connection, client_id, client_secret, code, opts={})
          @connection = connection
          @grant = Grant::AuthorizationCode.new(client_id, client_secret, code, opts)
        end

        def get_token

        end
      end
    end
  end
end