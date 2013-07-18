module OAuth2
  module Provider
    module Strategy
      class AuthorizationCode < Base
 
        def authorization_code(user)
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
          @token_datastore.generate_token(opts) 
        end

        def authorization_redirect_uri(user)
          params = {:code => authorization_code(user)}
          params[:state] = @request.state if request.state
          build_response_uri redirect_uri, :query => params
        end

      private

        def verify_authorization_code
          if @request.code.nil?          
            raise OAuth2::Provider::Error::InvalidRequest, "Authorization code required"
          end

          auth_code = @code_datastore.verify(
            :client => client_application,
            :code => @request.code,
            :redirect_uri => redirect_uri)
          if(auth_code.nil? || auth_code.expired? || auth_code.deactivated?)
            raise OAuth2::Provider::Error::InvalidGrant, "Authorization code was either invalid or not found"
          end
          auth_code
        end
      end
    end
  end
end