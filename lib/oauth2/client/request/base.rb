module OAuth2
  module Client
    module Request
      class  Base
        def initialize(connection, grant)
          @connection = connection
          @grant = grant
        end

        def request(opts)
          opts[:params] = @grant
          response = connection.make_request(opts)
          yield response if block_given?
        end

        def get_token(opts={}, &block)
          request(opts, block)
        end
      end
    end
  end
end