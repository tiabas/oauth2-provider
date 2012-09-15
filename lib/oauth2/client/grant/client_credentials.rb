module OAuth2
  module Client
    module Grant
      class ClientCredentials < Base

        def initialize(client_id, client_secret, opts={})
          super(client_id, client_secret, opts)
          self[:grant_type] => 'client_credentials'
        end

        def grant_type
          self[:grant_type]
        end
        
      end
    end
  end
end
