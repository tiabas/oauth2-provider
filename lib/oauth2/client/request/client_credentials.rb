module OAuth2
  module Client
    module Request
      class ClientCredentials
        def initialize(client, opts={})
          grant = Grant::ClientCredentials.new(client.client_id, client.client_secret, opts)
          super(client, grant)
        end
      end
    end
  end
end