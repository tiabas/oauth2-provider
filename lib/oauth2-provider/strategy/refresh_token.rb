module OAuth2
  module Provider
    module Strategy
      class RefreshToken < Base

        def access_token(opts={})
          # the refresh token grant type requires no further processing. Therefore return the token and
          # call it a day or bitch about being given a bogus token
          @token = @token_datastore.from_refresh_token(
            :client => client_application,
            :refresh_token => @request.refresh_token)
          unless @token
            raise OAuth2::Provider::Error::InvalidRequest, "invalid refresh token"
          end
          @token
        end

        def validate_refresh_token
          return true unless refresh_token.nil?
          raise OAuth2::Provider::Error::InvalidRequest, "refresh_token required"
        end
      end
    end
  end
end