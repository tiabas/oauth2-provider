module OAuth2
  module Client
    module Grant
      class AuthorizationCode < Base

        def initialize(client, opts={})
          super(client, opts)
          self[:grant_type] = 'authorization_code'
        end

      end
    end
  end
end
