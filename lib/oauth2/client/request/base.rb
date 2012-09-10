module OAuth2
  module Client
    module Request
      class  Base
        def initialize(client, grant)
          @client = client
          @grant = grant
        end

        def default_params
          @grant.to_hash
        end

        def request(opts={})
          method = opts[:method] || 'post'
          headers = opts[:headers]
          path = opts[:path]
          params = opts[:params] || {}
          params.merge(default_params)
          connection = @client.build_connection
          response = connection.make_request(path, params, method, headers)
          yield response if block_given?
        end

        def fetch_token(opts={}, &block)
          request(opts, block)
        end
      end
    end
  end
end