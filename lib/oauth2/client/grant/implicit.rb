module OAuth2
  module Client
    module Grant
      class Implicit < Base

        attr_reader :response_type

        def initialize(client_id, client_secret, response_type, opts={})
          super(client_id, client_secret, opts={})
          self[:response_type] = response_type
          self[:redirect_uri] = opts[:redirect_uri]
        end

      end
    end
  end
end
