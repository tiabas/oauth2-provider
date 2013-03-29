module OAuth2
  module Grant
    class Implicit < Base

      # http://example.com/cb#access_token=2YotnFZFEjr1zCsicMWpAA&state=xyz&token_type=example&expires_in=3600
      def access_token_redirect_uri(user, opts={})
        build_response_uri redirect_uri, :fragment => access_token_response(user, opts)
      end

      def access_token(opts={})
        if opts[:user].nil?
          raise "A user must be specified for this type of request"
        end

        opts[:refresh_token] = false
        opts[:scope] = @request.scope
        opts[:client]= client_application

        @token = @token_datastore.generate_token(client_application, opts) 

        @token
      end

    end
  end
end