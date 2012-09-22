module OAuth2
  module Client
    module Grant
      class Implicit < Base

        def initialize(client, response_type, opts={})
          super(client, opts)
          self[:response_type] = response_type
        end

        def to_params
          params = self.clone
          params.delete(:client_secret) if params[:client_secret]
          params
        end

        def authorization_path
          "#{@client.authorize_path}?#{to_query}"
        end

        def authorization_url
          to_url(@client.authorize_path)
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
