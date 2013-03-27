module OAuth2
  module Provider
    module Strategy
      class Base

        attr_reader :request

        def self.from_request_params(params)
          unless params.is_a?(Hash)
            raise "Expected a hash but got #{params.class.name}: #{params.inspect}"
          end
          request = OAuth2::Provider::Request.new(params)
          new(request)
        end

        def initialize(request, config_file=nil)
          unless request.is_a? OAuth2::Provider::Request
            raise "OAuth2::Provider::Request expected but got #{request.class.name}"
          end
          @request = request
          @request.validate!

          @config = Config.new(config_file)
          @user_datastore = @config.user_datastore
          @client_datastore = @config.client_datastore
          @token_datastore = @config.token_datastore
          @code_datastore = @config.code_datastore
        end

        def client_application
          @client || verify_client_id
        end

        def redirect_uri
          @redirect_uri || verify_redirect_uri
        end

        def error_redirect_uri(error)
          # http://example.com/cb#error=access_denied&error_description=the+user+denied+your+request
          unless error.respond_to? :to_hsh
            raise "Invalid error type. Expected OAuth2::OAuth2Error but got #{error.class.name} "
          end
          build_response_uri redirect_uri, :query => error.to_hsh
        end

        def verify_client_id
          @client = @client_datastore.find_client_with_id(@request.client_id)
          return @client if @client
          raise OAuth2::Provider::Error::InvalidClient, "unknown client"
        end

        def verify_request_scope
          # return true if @token_datastore.validate_scope(@request.scope)
          # raise OAuth2::Provider::Error::InvalidRequest, "invalid scope" 
        end

        def verify_redirect_uri
          # TODO: parse the URI hostname and path from request redirect
          @redirect_uri = @request.redirect_uri || client_application.redirect_uri
          if !client_application.validate_redirect_uri(@redirect_uri)
            raise OAuth2::Provider::Error::InvalidRequest, "invalid redirect uri"
          end
          @redirect_uri 
        end

      private

        # convenience method to build response URI  
        def build_response_uri(redirect_uri, opts={})
          query= opts[:query]
          fragment= opts[:fragment]
          unless ((query && query.is_a?(Hash)) || (fragment && fragment.is_a?(Hash)))
            # TODO: make sure error message is more descriptive i.e query if query, fragment if fragment
            raise "Hash expected but got: query: #{query.inspect}, fragment: #{fragment.inspect}"
          end
          uri = Addressable::URI.parse redirect_uri
          temp_query = uri.query_values || {}
          temp_frag = uri.fragment || nil
          uri.query_values = temp_query.merge(query) unless query.nil?
          uri.fragment = Addressable::URI.form_encode(fragment) unless fragment.nil?
          uri.to_s
        end
      end
    end
  end
end
