module OAuth2Provider
  class DataAdapter

    def client_id_valid?(oauth_request)
      raise NotImplementedError.new("#{self.class.name}#client_id_valid? is an abstract method")
    end

    def refresh_token_valid?(oauth_request)
      raise NotImplementedError.new("#{self.class.name}#refresh_token_valid is an abstract method")
    end

    def authorization_code_valid?(oauth_request)
      raise NotImplementedError.new("#{self.class.name}#authorization_code_valid is an abstract method")
    end

    def redirect_uri_valid?(oauth_request)
      raise NotImplementedError.new("#{self.class.name}#redirect_uri_valid is an abstract method")
    end

    def resource_owner_credentials_valid?(oauth_request)
      raise NotImplementedError.new("#{self.class.name}#resource_owner_credentials_valid is an abstract method")
    end

    def generate_authorization_code(oauth_request)
      raise NotImplementedError.new("#{self.class.name}##generate_authorization_code is an abstract method")
    end

    def generate_access_token(oauth_request)
      raise NotImplementedError.new("#{self.class.name}#generate_access_token is an abstract method")
    end

    def token_from_client_credentials(oauth_request)
      raise NotImplementedError.new("#{self.class.name}#token_from_client_credentials is an abstract method")
    end

    def token_from_refresh_token(oauth_request)
      raise NotImplementedError.new("#{self.class.name}#token_from_refresh_token is an abstract method")
    end

    def token_from_authorization_code(oauth_request)
      raise NotImplementedError.new("#{self.class.name}#token_from_authorization_code is an abstract method")
    end
  end
end