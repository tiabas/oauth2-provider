module OAuth2
  module Provider
    module Strategy
      class AuthorizationCode

        def authorization_code(user)
          unless @request.response_type?(:code)
            raise OAuth2::Provider::Error::UnsupportedResponseType, "unsupported response_type #{@response_type}"
          end
          @code_datastore.generate_authorization_code(
            :client => client_application,
            :user => user,
            :redirect_uri => redirect_uri)
        end

        def access_token(opts={})
          code = verify_authorization_code

          opts[:scope] = @request.scope
          opts[:user]  = code.user
          opts[:client]= client_application
          @token = @token_datastore.generate_token(opts) 

          code.deactivate!

          @token
        end

        def authorization_redirect_uri(user)
          build_response_uri redirect_uri, :query => authorization_code(user)
        end

      private

        def verify_authorization_code
          auth_code = @code_datastore.verify(
            :client => client_application,
            :code => @request.code,
            :redirect_uri => redirect_uri)
          if(auth_code.nil? || auth_code.expired? || auth_code.deactivated?)
            raise OAuth2::Provider::Error::InvalidGrant, "invalid authorization code"
          end
          auth_code
        end

        def validate_authorization_code
          return true unless code.nil?
          raise OAuth2::Provider::Error::InvalidRequest, "code required"
        end
      end
    end
  end
end