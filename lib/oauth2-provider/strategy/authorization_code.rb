module OAuth2Provider
  module Strategy
    class AuthorizationCode

      def authorization_code(opts={})
        unless @request.response_type?(:code)
          raise OAuth2Provider::Error::UnsupportedResponseType, "unsupported response_type #{@response_type}"
        end
        @adapter.generate_authorization_code(@request, opts)
      end

      def access_token(opts={})
        @adapter.token_from_authorization_code(@request, opts) 
      end

      def validate!
        super
        unless @request.code
          raise OAuth2Provider::Error::InvalidRequest, "authorization code required"
        end

        unless  @adapter.authorization_code_valid?(@request)
          raise OAuth2Provider::Error::InvalidGrant, "invalid authorization code"
        end

        unless @adapter.redirect_uri_valid?(@request)
          raise OAuth2Provider::Error::InvalidGrant, "invalid redirect_uri"
        end
        yield self
      end
    end
  end
end