module OAuth2Provider
  module Strategy
    class Base

      attr_reader :request

      def initialize(request, adapter)
        unless request.is_a? OAuth2Provider::Request
          raise "OAuth2Provider::Request expected but got #{request.class.name}"
        end
        @request = request
        @adapter = adapter
      end

      def validate!
        unless @adapter.client_id_valid?(@request)
          raise OAuth2Provider::Error::InvalidRequest, "unknown client"
        end
        yield self
      end

      def valid?
        begin
          validate!
          true
        rescue
          false
        end
      end
    end
  end
end
