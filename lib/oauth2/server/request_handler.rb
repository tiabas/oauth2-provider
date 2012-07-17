module OAuth2
  module Server
    class RequestHandler

      attr_accessor :request

      def initialize(request)
        @request = request
      end

      def authorization_code
        # 
        request.validate
        unless request.response_type_code?
          raise OAuth2Error::UnsupportedResponseType, "The response type, #{@response_type}, is not valid for this request"
        end
        generate_authorization_code
      end

      def authorization_response
        # {
        #   :code => "2YotnFZFEjr1zCsicMWpAA", 
        #   :state => "auth",
        # }
        response = { 
          :code => authorization_code
        }
        response[:state] = request.state unless request.state.nil?
        response 
      end

      def authorization_redirect_uri(allow=false) 
        # https://client.example.com/cb?code=SplxlOBeZQQYbYS6WxSbIA&state=xyz
        build_response_uri authorization_response
      end

      def access_token
        # {
        #   :access_token => "2YotnFZFEjr1zCsicMWpAA", 
        #   :token_type => "bearer",
        #   :expires_in => 3600,
        #   :refresh_token => "tGzv3JOkF0XG5Qx2TlKWIA",
        # }
        request.validate
        unless (request.grant_type.nil? && request.response_type_token?)
          raise OAuth2Error::UnsupportedResponseType, "The response type provided is not valid for this request"
        end
        generate_access_token.to_hash
      end

      def access_token_redirect_uri
        # http://example.com/cb#access_token=2YotnFZFEjr1zCsicMWpAA&state=xyz&token_type=example&expires_in=3600
        build_response_uri :fragment_params => access_token
      end

      private

      # convenience method to build response URI  
      def build_response_uri(query_params=nil, fragment_params=nil)
        uri = Addressable::URI.parse redirect_uri
        uri.query_values = Addressable::URI.form_encode query_params unless query_params.nil?
        uri.fragment = Addressable::URI.form_encode fragment_params unless fragment_params.nil?
        return uri
      end

      def generate_authorization_code
        raise NotImplementedError.new("You must implement #{name}.") 
      end

      def generate_access_token
        raise NotImplementedError.new("You must implement #{name}.")
      end
    end
  end
end
