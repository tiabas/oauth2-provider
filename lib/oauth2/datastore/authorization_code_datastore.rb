module OAuth2
  module DataStore
    class AuthorizationCodeDataStore < MockDataStore
        Include OAuth2::Helper

        private_class_method :new

        def self.generate_for_client(c_id)
          kode = new(
                :code => OAuth2::Helper.generate_urlsafe_key,
                :client_id => c_id
              )
          self.instances || = []
          self.instances << kode
        end

        def self.verify_client_and_code(c_id, auth_code)
          find :client_id => c_id, :code => auth_code
        end
    end
  end
end