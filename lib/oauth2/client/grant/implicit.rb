module OAuth2
  module Client
    module Grant
      class Implicit < Base

        attr_reader :response_type

        def initialize(client_id, client_secret, response_type, opts={})
          super(client_id, client_secret, opts)
          @response_type = response_type
        end

        def to_params
          {
            :response_type => @response_type
          }.merge!(super)
        end
      end
    end
  end
end
