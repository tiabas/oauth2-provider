module OAuth2
  module Client
    module Grant
      class Base < Hash

        attr_accessor :client_id, :client_secret

        class << self
          protected :new
        end

        def initialize(client_id, client_secret)
          self[:client_id] = client_id
          self[:client_secret] = client_secret
        end

        def to_s
          Addressible::URI.form_encode(self)
        end
      end
    end
  end
end
