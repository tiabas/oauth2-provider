module OAuth2
  module Client
    module Request
      class AuthorizationCode < Base
        def initialize(client, code, opts={})
          grant = Grant::AuthorizationCode.new(client.client_id, client.client_secret, code, opts)
          super(client, grant)
        end
      end
    end
  end
end