module OAuth2
  module Client
    module Request
      class Password
        def initialize(client, username, password, opts={})
          grant = Grant::Password.new(client.client_id, client.client_secret, username, password, opts)
          super(client, grant) 
        end
      end
    end
  end
end