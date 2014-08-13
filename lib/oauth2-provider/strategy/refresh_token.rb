module OAuth2Provider
  module Strategy
    class RefreshToken < Base

      def access_token(opts={})
        @adapter.token_from_refresh_token(@request, opts)
      end

      def validate!
        super
        unless refresh_token
          raise OAuth2Provider::Error::InvalidRequest, "refresh token required"
        end

        unless @adapter.refresh_token_valid?(@request)
          raise OAuth2Provider::Error::InvalidRequest, "invalid refresh token"
        end
        yield self
      end
    end
  end
end