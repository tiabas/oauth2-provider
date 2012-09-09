module OAuth2
  module Client
    module Request
      class Password
        def initialize(connection, client_id, client_secret, username, password, opts={})
          @connection = connection
          @grant = Grant::Password.new(client_id, client_secret, username, password, opts)
        end

        def get_token

        end
      end
    end
  end
end