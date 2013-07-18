module OAuth2
  module Provider
    module Strategy
      class ResourceOwner

        def user
          @user || authenticate_user_credentials
        end

        def authenticate_user_credentials
          validate_user_credentials
          @user = @user_datastore.authenticate request.username, request.password
          if @user.nil?
            raise OAuth2::Provider::Error::AccessDenied, "user authentication failed"
          end
          @user
        end

        def access_token(opts={})
          opts[:scope] = @request.scope
          opts[:user]  = authenticate_user_credentials
          opts[:client]= client_application

          @token = @token_datastore.generate_token(opts) 
          @token
        end

        def validate_user_credentials
          if @username.nil? || @password.nil?
            @errors[:user_credentials] = []
            @errors[:user_credentials] << "username" if @username.nil?
            @errors[:user_credentials] << "password" if @password.nil?
            @errors[:user_credentials] << "required"
            raise OAuth2::Provider::Error::InvalidRequest, @errors[:user_credentials].join(" ")
          end
          true
        end
      end
    end
  end
end