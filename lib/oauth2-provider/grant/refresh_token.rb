module OAuth2Provider
  module Strategy
    class RefreshToken < Base

      def access_token(opts={})
        @adapter.token_from_refresh_token(@request, opts)
      end

      def validate!
        unless @request.refresh_token
          raise OAuth2Provider::Error::InvalidGrant, "refresh token required"
        end

        unless @adapter.refresh_token_valid?(@request)
          raise OAuth2Provider::Error::InvalidGrant, "invalid refresh token"
        end
        super
      end
    end
  end
end
