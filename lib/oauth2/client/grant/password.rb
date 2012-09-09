module OAuth2
  module Client
    module Grant
      class Password < Base

        attr_reader :grant_type
        attr_accessor :username, :password

        def initialize(client_id, client_secret, username, password, opts={})
          super(client_id, client_secret, opts)
          @username = username
          @password = password
          @grant_type = 'password'
        end

        def to_params
          {
            :username => @username,
            :password => @password,
            :grant_type => @grant_type
          }.merge!(super)
        end
      end
    end
  end
end
