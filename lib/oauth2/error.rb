require 'addressable/uri'
module OAuth2
  module OAuth2Error
    class Error < StandardError

      attr_reader :error, :error_description

      def initialize(msg=nil)
        super msg
        @error = self.class.name.gsub(/^.*::/, '')
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