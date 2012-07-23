module OAuth2
  module DataStore
    class AuthorizationCodeDataStore < MockDataStore

        private_class_method :new

        class << self
          include OAuth2::Helper

          def self.generate_for_client(c_id)
            self.instances ||= []
            kode = new
            kode.merge!({
                  :id => self.instances.length,
                  :code => generate_urlsafe_key,
                  :client_id => c_id
                })
            self.instances << kode
          end

          def self.verify_client_and_code(c_id, auth_code)
            find :client_id => c_id, :code => auth_code
          end
        end
    end
  end
end