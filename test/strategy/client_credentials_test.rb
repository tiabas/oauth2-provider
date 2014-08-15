class ClientCredentialsTest < MiniTest::Unit::TestCase
  def setup
        @code = 'G3Y6jU3a'
        @client_id = 's6BhdRkqt3'
        @client_secret = 'SplxlOBeZQQYbYS6WxSbIA'
        @access_token = '2YotnFZFEjr1zCsicMWpAA'
        @refresh_token = 'tGzv3JOkF0XG5Qx2TlKWIA'
        @expires_in = 3600
        @state = 'xyz'
        @scope = "scope1 scope2"
        @token_type = 'Bearer'
        @redirect_uri = 'https://client.example.com/oauth_v2/cb'

        @request = OAuth2Provider::Request.new({
                            :client_id => @client_id,
                            :client_secret => @client_secret,
                            :grant_type => 'client_credentials'
                            })
        @token = mock()
        @adapter = mock()
  end

    # Grant type: client_credentials
    def test_should_raise_invalid_request_when_client_secret_missing
        request = OAuth2Provider::Request.new({
                    :client_id => @client_id,
                    :grant_type => 'client_credentials'
                })
        grant = OAuth2Provider::Strategy::ClientCredentials.new(request, @adapter)
        assert_raises OAuth2Provider::Error::InvalidRequest do
            grant.validate!
        end
    end

    def test_should_raise_invalid_request_when_client_credentials_invalid
        grant = OAuth2Provider::Strategy::ClientCredentials.new(@request, @adapter)
        @adapter.expects(:client_credentials_valid?).with(@request).returns(false)
        assert_raises OAuth2Provider::Error::InvalidRequest do
            grant.validate!
        end
    end

    def test_should_return_access_token
        grant = OAuth2Provider::Strategy::ClientCredentials.new(@request, @adapter)
        @adapter.expects(:token_from_client_credentials).with(@request, {}).returns(@token)
        grant.access_token
    end
end
