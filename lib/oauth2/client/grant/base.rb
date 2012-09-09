module OAuth2
  module Client
    module Grant
      class Base

        attr_accessor :client_id, :client_secret, :redirect_uri
        
        def initialize(client_id, client_secret, opts={})
          @client_id = client_id
          @client_secret = client_secret
          @redirect_uri = opts[:redirect_uri]
        end

        def to_params
          params = {
            :client_id => @client_id,
            :client_secret => @client_secret
          }
          params[:redirect_uri] = @redirect_uri if @redirect_uri
          params
        end
    
        def to_s
          Addressible::URI.form_encode(to_params)
        end
      end
    end
  end
end
