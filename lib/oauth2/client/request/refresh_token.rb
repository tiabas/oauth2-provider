module OAuth2
  module Client
    module Request
      class RefreshToken
        def initialize(connection, client_id, client_secret, refresh_token, opts={})
          @connection = connection
          @grant = Grant::RefreshToken.new(client_id, client_secret, refresh_token, opts)
        end

        def get_token

        end
      end
    end
  end
end