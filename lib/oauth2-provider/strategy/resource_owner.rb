module OAuth2Provider
  module Strategy
    class ResourceOwner

      def access_token(opts={})
        @adapter.generate_access_token(@request, opts) 
      end

      def validate!
        super
        unless @username && @password
          @errors[:user_credentials] = []
          @errors[:user_credentials] << "username required" unless @username
          @errors[:user_credentials] << "password required" unless @password
          raise OAuth2Provider::Error::InvalidCredentials, @errors[:user_credentials].join(", ")
        end
        unless @adapter.resource_owner_credentials_valid?(@request)
          raise OAuth2Provider::Error::AccessDenied, "invalid user credentials"
        end
      end
    end
  end
end