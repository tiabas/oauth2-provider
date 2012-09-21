module OAuth2
  module Client
    module Grant
      class Implicit < Base

        def initialize(client, response_type, opts={})
          super(client, opts)
          self[:response_type] = response_type
        end

        def get_authorization_uri(opts={})
          opts[:path]   ||= @client.authorize_path
          opts[:method] ||= 'get'
          request(opts)
        end

      end
    end
  end
end
