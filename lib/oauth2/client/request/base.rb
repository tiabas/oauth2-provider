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
          response = make_request(path, params, method, headers)
          yield response if block_given?
        end

        def http_connection()
          http = Net::HTTP.new(host)
          http.use_ssl = @use_ssl
          http
        end

        def make_request(path, params, method, headers=nil)
          connection = http_connection
          if method.to_s == 'get'
            query = Addressable::URI.form_encode(params)
            uri = query ? [path, query].join("?") : path
            connection.get uri, headers
          else
            connection.post path, params, headers
          end
        end

        def fetch_token(opts={}, &block)
          request(opts, block)
        end
      end
    end
  end
end