module OAuth2
  module Client
    module Grant
      class AuthorizationCode < Base

        attr_reader :grant_type

        def initialize(client_id, client_secret, params={})
          super(client_id, client_secret, opts)
          self[:grant_type] = 'authorization_code'
        end

      end
    end
  end
end
