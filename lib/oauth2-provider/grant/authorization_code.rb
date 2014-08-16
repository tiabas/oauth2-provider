module OAuth2Provider
  module Strategy
    class AuthorizationCode < Base
      def access_token(opts = {})
        @adapter.token_from_authorization_code(@request, opts)
      end

      def validate!
        unless  @adapter.authorization_code_valid?(@request)
          fail OAuth2Provider::Error::InvalidGrant, 'invalid authorization code'
        end

        unless @adapter.redirect_uri_valid?(@request)
          fail OAuth2Provider::Error::InvalidGrant, 'invalid redirect_uri'
        end
        super
      end
    end
  end
end
