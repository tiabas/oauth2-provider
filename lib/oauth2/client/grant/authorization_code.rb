module OAuth2
  module Client
    module Grant
      class AuthorizationCode < Base

        attr_reader :grant_type

        def initialize(client_id, client_secret, opts={})
          super(client_id, client_secret, opts)
          @grant_type = 'authorization_code'
        end

        def to_params
          {
            :grant_type => @grant_type
          }.merge!(super)
        end
      end
    end
  end
end
