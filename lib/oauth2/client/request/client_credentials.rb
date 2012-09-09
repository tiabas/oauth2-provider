module OAuth2
  module Client
    module Request
      class ClientCredentials
        def initialize(connection, client_id, client_secret, opts={})
          @connection = connection
          @grant = Grant::ClientCredentials.new(client_id, client_secret, opts)
        end

        def get_token

        end
      end
    end
  end
end