require 'addressable/uri'

module OAuth2
  module OAuth2Error
    class Error < StandardError

      attr_reader :code, :error
      
      def self.new
        raise "#{ self.class.to_s} is an abstract class!"
      end

      def initialize(msg)
        message = ["OAuth Error #{ self.class.to_s} "]
        message << msg 
        super(message.join(","))
        @error = "#{ self.class.to_s}"
        @code = 400
      end

      def error_description
        message
      end

      def to_uri_component
        Addressable::URI.form_encode({
          :error             => error,
          :error_description => error_description
        })
      end
    end
  end
end