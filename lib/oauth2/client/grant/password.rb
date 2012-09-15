module OAuth2
  module Client
    module Grant
      class Password < Base

        attr_reader :grant_type
        attr_accessor :username, :password

        def initialize(client_id, client_secret, username, password, opts={})
          super(client_id, client_secret, opts)
          self[:username] = username
          self[:password] = password
          self[:grant_type] = 'password'
        end

        def username
          self[:username]
        end

        def password
          self[:password]
        end

        def grant_type
          self[:grant_type]
        end

      end
    end
  end
end
