module OAuth2
  module Provider
    module Strategy
      class ClientCredentials < Base

        attr_reader :client_id, :client_secret

        def access_token(opts={})
          validate_client_credentials
          {
            :scope => @request.scope
          }.merge(opts)
          @token_datastore.generate_client_token(client_application, opts)
        end

        def validate_client_credentials
          unless @client_id && @client_secret
            @errors[:client] = []
            @errors[:client] << "client_id"     if @client_id.nil?
            @errors[:client] << "client_secret" if @client_secret.nil?
            @errors[:client] << "required"
            raise OAuth2::Provider::Error::InvalidRequest, @errors[:client].join(" ")
          end
          true
        end
      end
    end
  end
end