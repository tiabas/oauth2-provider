module OAuth2
  module Client
    module Grant
      class RefreshToken < Base
        attr_reader :response_type
        attr_accessor :refresh_token

        def initialize(client_id, client_secret, refresh_token, opts={})
          super(client_id, client_secret, opts)
          @refresh_token = refresh_token
          @grant_type = 'refresh_token'
        end

        def to_params
          {
            :refresh_token => @refresh_token,
            :grant_type => @grant_type
          }.merge!(super)
        end
      end
    end
  end
end
