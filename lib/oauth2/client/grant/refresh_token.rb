module OAuth2
  module Client
    module Grant
      class RefreshToken < Base

        attr_reader :response_type
        attr_accessor :refresh_token

        def initialize(client_id, client_secret, refresh_token, opts={})
          super(client_id, client_secret)
          self[:refresh_token] = refresh_token
          self[:grant_type] = 'refresh_token'
        end

      end
    end
  end
end
