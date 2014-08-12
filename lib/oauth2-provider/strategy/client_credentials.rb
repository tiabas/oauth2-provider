module OAuth2Provider
  module Strategy
    class ClientCredentials < Base

      attr_reader :client_id, :client_secret

      def access_token(opts={})
        @adapter.token_from_client_credentials(@request, opts)
      end

      def validate!
        # NOTE: We do not call `super` here to prevent facilitating harvesting of 
        # valid client ID's
        unless @client_secret
          raise OAuth2Provider::Error::InvalidRequest, "client_secret required"
        end

        unless @adapter.client_credentials_valid?(@request)
          raise OAuth2Provider::Error::InvalidRequest, "invalid client credentials"
        end
        yield self
      end
    end
  end
end