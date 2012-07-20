require 'addressable/uri'

module OAuth2
  module OAuth2Error
    class Error < StandardError

      attr_reader :code, :error

      def initialize(msg=nil)
        message = msg || "OAuth Error: #{ self.class.to_s.downcase }"
        super message
        @error = "#{ self.class.to_s}"
        @code = 400
      end

      def error_description
        message
      end

      def to_hsh
        {
          :error             => error,
          :error_description => error_description,
          :code              => code
        }
      end

      def to_uri_component
        Addressable::URI.form_encode to_hsh
      end
    end
  end
end