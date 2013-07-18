class RefreshTokenGrantTest < MiniTest::Unit::TestCase
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
    @client_app = mock()
    @client_app.stubs(:redirect_uri).returns(@redirect_uri)
    @token = mock()
    @token_response = {
      :access_token => @access_token,
      :refresh_token => @refresh_token,
      :token_type => @token_type,
      :expires_in =>  @expires_in,
    }
    @token.stubs(:to_hash).returns(@token_response)
    @config_file = TEST_ROOT+'/mocks/oauth_config.yml'
    @mock_code = mock()
    @mock_user = mock()
    @mock_client = mock()
    @mock_token = mock()
    @config = mock()
    @config.stubs(:user_datastore).returns(@mock_user)
    @config.stubs(:client_datastore).returns(@mock_client)
    @config.stubs(:code_datastore).returns(@mock_code)
    @config.stubs(:token_datastore).returns(@mock_token)
    @config.client_datastore.stubs(:find_client_with_id).returns(@client_app)
    OAuth2::Provider::Config.stubs(:new).returns(@config)
  end
  # Grant type: refresh_token
  def test_should_raise_invalid_request_with_grant_type_refresh_token_but_no_refresh_token
    request = OAuth2::Provider::Request.new({
                        :client_id => @client_id,
                        :grant_type => 'refresh_token',
                        })
    assert_raises OAuth2::Provider::Error::InvalidRequest do
      request.validate_refresh_token
    end
  end

  def test_should_pass_with_grant_type_refresh_token_and_refresh_token
    request = OAuth2::Provider::Request.new({
                        :client_id => @client_id,
                        :grant_type => 'refresh_token',
                        :refresh_token => @refresh_token
                        })
    assert request.validate_refresh_token
  end
end