module OAuth2Provider
  module Strategy
    class Base
      attr_reader :request

      def initialize(request, adapter)
        @request = request
        @adapter = adapter
      end

      def validate!
        unless @adapter.client_id_valid?(@request)
          fail OAuth2Provider::Error::InvalidRequest, 'unknown client'
        end
        yield self if block_given?
      end

      def valid?
        validate!
        true
      rescue
        false
      end
    end
  end
end
