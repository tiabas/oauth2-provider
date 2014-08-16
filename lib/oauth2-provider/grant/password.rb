module OAuth2Provider
  module Strategy
    class Password < Base
      def access_token(opts = {})
        @adapter.generate_access_token(@request, opts)
      end

      def validate!
        username = @request.username
        password = @request.password
        unless username && password
          errors = []
          errors << 'username required' unless username
          errors << 'password required' unless password
          fail OAuth2Provider::Error::InvalidGrant, errors.join(', ')
        end
        unless @adapter.resource_owner_credentials_valid?(@request)
          fail OAuth2Provider::Error::AccessDenied, 'invalid resource owner credentials'
        end
        super
      end
    end
  end
end
