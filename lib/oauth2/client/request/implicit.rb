module OAuth2
  module Client
    module Request
      class Implicit
        def initialize(client, response_type, opts={})
          grant = Grant::Implicit.new(client.client_id, client.client_secret, response_type, opts)
          super(client, grant)
        end

        def authorization_uri

        end

        def fetch_code

        end

        def fetch_code
          raise "NotImplemented"
        end
      end
    end
  end
end