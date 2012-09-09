module OAuth2
  module Client
    module Request
      class Implicit
        def initialize(connection, client_id, client_secret, response_type, opts={})
          @connection = connection
          @grant = Grant::Implicit.new(client_id, client_secret, response_type, opts)
        end

        def authorization_uri

        end
      end
    end
  end
end