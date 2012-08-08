require 'addressable/uri'
module OAuth2
  module OAuth2Error
    class Error < StandardError
      
      class << self; attr_accessor :code; end
      
      attr_reader :error, :error_description

      def initialize(msg=nil)
        msg ||= "an error occurred" 
        super msg
        @error = self.class.name
        @error_description = msg
      end

      def normalized_error
        # Taken from rails active support
        err = self.class.name.gsub(/^.*::/, '')
        err = err.gsub(/([A-Z\d]+)([A-Z][a-z])/,'\1_\2')
        err = err.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
        err.downcase
      end

      def to_hsh
        {
          :error             => normalized_error,
          :error_description => @error_description
        }
      end

      def to_uri_component
        Addressable::URI.form_encode to_hsh
      end

      def http_error_response(request)
        unless request.is_a? OAuth2::Server::Request
          raise "OAuth2::Server::Request expected but got #{request.class.name}"
        end
        OAuth2::Helper.build_response_uri request.redirect_uri, self.to_hsh
      rescue Exception => e
        raise OAuth2::OAuth2Error::ServerError, e.message
      end
    end

    class AccessDenied < Error
      @code = 401
    end

    class InvalidClient < Error
      @code = 401
    end

    class InvalidGrant < Error
      @code = 401
    end

    class InvalidRequest < Error
      @code = 400
    end

    class InvalidScope < Error
      @code = 400
    end

    class ServerError < Error
      @code = 500
    end

    class UnauthorizedClient < Error
      @code = 400
    end

    class UnsupportedGrantType < Error
      @code = 400
    end

    class UnsupportedResponseType < Error
      @code = 400
    end

    class TemporarilyUnavailable < Error
      @code = 503
    end

    class RateLimitExceeded < Error
      @code = 403
    end
  end
end