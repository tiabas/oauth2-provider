require 'addressable/uri'
module OAuth2
  module OAuth2Error
    class Error < StandardError
      attr_reader :error, :error_description

      def initialize(msg=nil)
        super msg
        @error = self.class.name.gsub(/^.*::/, '')
                 .gsub(/([A-Z\d]+)([A-Z][a-z])/,'\1_\2')
                 .gsub!(/([a-z\d])([A-Z])/,'\1_\2')
                 .downcase
        @error_description = msg
      end

      def to_hsh
        {
          :error             => @error,
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

    class AccessDenied            < Error; end
    class InvalidClient           < Error; end
    class InvalidGrant            < Error; end
    class InvalidRequest          < Error; end
    class InvalidScope            < Error; end
    class ServerError             < Error; end
    class UnauthorizedClient      < Error; end
    class UnsupportedGrantType    < Error; end
    class UnsupportedResponseType < Error; end
    class TemporarilyUnavailable  < Error; end
  end
end