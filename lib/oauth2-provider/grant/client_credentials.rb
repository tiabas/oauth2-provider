module OAuth2Provider
  module Strategy
    class ClientCredentials < Base
      attr_reader :client_id, :client_secret

      def access_token(opts = {})
        @adapter.token_from_client_credentials(@request, opts)
      end

      def validate!
        # NOTE: We do not call `super` here to prevent facilitating harvesting of
        # valid client ID's
        unless @request.client_secret
          fail OAuth2Provider::Error::InvalidRequest, 'client_secret required'
        end

        unless @adapter.client_credentials_valid?(@request)
          fail OAuth2Provider::Error::InvalidRequest, 'invalid client credentials'
        end
        super
      end
    end
  end
end
