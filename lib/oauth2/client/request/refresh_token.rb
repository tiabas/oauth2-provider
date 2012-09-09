module OAuth2
  module Client
    module Request
      class RefreshToken
        def initialize(client, refresh_token, opts={})
          grant = Grant::RefreshToken.new(client.client_id, client.client_secret, refresh_token, opts)
          super(client, grant)
        end
      end
    end
  end
end