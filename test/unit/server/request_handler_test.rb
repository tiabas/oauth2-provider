class TestOAuth2RequestHandler < MiniTest::Unit::TestCase

  def setup
    @code = 'G3Y6jU3a'
    @client_id = 's6BhdRkqt3'
    @client_secret = 'SplxlOBeZQQYbYS6WxSbIA'
    @access_token = '2YotnFZFEjr1zCsicMWpAA'
    @refresh_token = 'tGzv3JOkF0XG5Qx2TlKWIA'
    @expires_in = 3600
    @state = 'xyz'
    @token_type = 'bearer'
    @redirect_uri = create_redirect_uri
    @token_response = {
      :access_token => @access_token,
      :refresh_token => @refresh_token,
      :token_type => @token_type,
      :expires_in =>  @expires_in,
    }
    @config = {
      :user_datastore => mock(),
      :client_datastore => mock(),
      :code_datastore => mock(),
      :token_datastore => mock()
    }
    @mock_code = mock()
    @mock_user = mock()
    @mock_client = mock()
    @config[:client_datastore].stubs(:find_client_with_id).returns(@mock_client)
  end
  # Authorization Code Flow

  # Authorization redirect URI
  def test_should_raise_invalid_client_with_response_type_code_and_invalid_client_id
    request = OAuth2::Server::Request.new({
                        :client_id => @client_id,
                        :response_type => 'code',
                        :redirect_uri => @redirect_uri,
                        :state => @state
                        })
    @config[:client_datastore].stubs(:find_client_with_id).returns(nil)
    request_handler = OAuth2::Server::RequestHandler.new(request, @config)
    
    assert_raises OAuth2::OAuth2Error::InvalidClient do
      request_handler.fetch_authorization_code
    end
  end

  def test_should_return_authorization_code_with_response_type_code_and_valid_client_id
    request = OAuth2::Server::Request.new({
                        :client_id => @client_id,
                        :response_type => 'code',
                        :redirect_uri => @redirect_uri,
                        :state => @state
                        })
    # @config[:client_datastore].stubs(:find_client_with_id).returns(Object.new)
    @config[:code_datastore].stubs(:generate_authorization_code).returns(@code)
    request_handler = OAuth2::Server::RequestHandler.new(request, @config)

    assert_equal @code, request_handler.fetch_authorization_code
  end

  def test_should_return_code_and_state_with_response_type_code_and_valid_client_id
    request = OAuth2::Server::Request.new({
                        :client_id => @client_id,
                        :response_type => 'code',
                        :redirect_uri => @redirect_uri,
                        :state => @state
                        })
    @config[:code_datastore].stubs(:generate_authorization_code).returns(@code)

    request_handler = OAuth2::Server::RequestHandler.new(request, @config)
    response = { :code=> @code, :state=> @state }

    assert_equal response, request_handler.authorization_code_response
  end

  def test_should_return_code_with_response_type_code_and_valid_client_id
    request = OAuth2::Server::Request.new({
                        :client_id => @client_id,
                        :response_type => 'code',
                        :redirect_uri => @redirect_uri
                        })
    @config[:code_datastore].stubs(:generate_authorization_code).returns(@code)

    request_handler = OAuth2::Server::RequestHandler.new(request, @config)
    response = { :code=> @code }

    assert_equal response, request_handler.authorization_code_response
  end

  def test_should_return_authorization_redirect_with_response_type_code_and_valid_client_id
    request = OAuth2::Server::Request.new({
                        :client_id => @client_id,
                        :response_type => 'code',
                        :redirect_uri => @redirect_uri,
                        :state => @state
                        })
    @config[:code_datastore].stubs(:generate_authorization_code).returns(@code)

    request_handler = OAuth2::Server::RequestHandler.new(request, @config)
    redirect_uri = "#{@redirect_uri}?code=#{@code}&state=#{@state}"

    assert_equal redirect_uri, request_handler.authorization_redirect_uri
  end

  def test_should_raise_unsupported_response_type_with_invalid_response_type_code_and_client_id
    request = OAuth2::Server::Request.new({
                        :client_id => @client_id,
                        :response_type => 'code',
                        :redirect_uri => @redirect_uri,
                        :state => @state
                        })
    request_handler = OAuth2::Server::RequestHandler.new(request, @config)
    
    assert_raises OAuth2::OAuth2Error::InvalidRequest do
      request_handler.access_token_response @mock_user
    end
  end

  def test_should_raise_error_with_grant_type_authorization_code_and_invalid_code
    request = OAuth2::Server::Request.new({
                        :client_id => @client_id,
                        :grant_type => 'authorization_code',
                        :redirect_uri => @redirect_uri,
                        :code => @code,
                        :state => @state
                        })
    @config[:code_datastore].stubs(:verify_authorization_code).with(@client_id, @code, @redirect_uri).returns(nil)
    request_handler = OAuth2::Server::RequestHandler.new(request, @config)

    assert_raises OAuth2::OAuth2Error::InvalidGrant do
      request_handler.access_token_response @mock_user
    end
  end

  def test_should_return_token_hash_with_grant_type_authorization_code_and_valid_code
    redirect_uri = "#{@redirect_uri}#access_token=#{@access_token}&state=#{@state}&token_type=#{@token_type}&expires_in=#{@expires_in}"
    request = OAuth2::Server::Request.new({
                        :client_id => @client_id,
                        :grant_type => 'authorization_code',
                        :redirect_uri => @redirect_uri,
                        :code => @code,
                        :state => @state
                        })
    request_handler = OAuth2::Server::RequestHandler.new(request, @config)

    @config[:code_datastore].expects(:verify_authorization_code).with(@client_id, @code, @redirect_uri).returns(@mock_code)
    @mock_code.expects(:expired?).returns(false)
    @mock_code.expects(:deactivated?).returns(false)
    @config[:token_datastore].expects(:generate_user_token).with(@mock_user, {}).returns(@token_response)
    @mock_code.expects(:deactivate!).returns(false)
    
    assert_equal @token_response, request_handler.access_token_response(@mock_user)
  end

  def test_should_raise_error_with_grant_type_client_credentials_and_invalid_credentials
    request = OAuth2::Server::Request.new({
                        :client_id => @client_id,
                        :client_secret => @client_secret,
                        :grant_type => 'client_credentials',
                        :state => @state
                        })
    request_handler = OAuth2::Server::RequestHandler.new(request, @config)
    @mock_client.expects(:verify_secret).with(@client_secret).returns(false)
    assert_raises OAuth2::OAuth2Error::InvalidClient do
      request_handler.access_token_response(@mock_user)
    end
  end

  def test_should_return_token_hash_with_grant_type_client_credentials_and_valid_credentials
    request = OAuth2::Server::Request.new({
                        :client_id => @client_id,
                        :client_secret => @client_secret,
                        :grant_type => 'client_credentials',
                        :state => @state
                        })
    request_handler = OAuth2::Server::RequestHandler.new(request, @config)
    @mock_client.expects(:verify_secret).with(@client_secret).returns(true)
    @config[:token_datastore].expects(:generate_user_token).with(@mock_user, {}).returns(@token_response)
    assert_equal @token_response, request_handler.access_token_response(@mock_user)
  end

  def test_should_raise_error_with_grant_type_password_and_invalid_credentials
    request = OAuth2::Server::Request.new({
                        :client_id => @client_id,
                        :username => 'jacksparrow',
                        :password => 'Q3zXj3w',
                        :grant_type => 'password',
                        :state => @state
                        })
    request_handler = OAuth2::Server::RequestHandler.new(request, @config)
    @config[:user_datastore].expects(:authenticate).with('jacksparrow', 'Q3zXj3w').returns(false)
    assert_raises OAuth2::OAuth2Error::AccessDenied do
      request_handler.access_token_response(@mock_user)
    end
  end

  def test_should_return_token_hash_with_grant_type_password_and_valid_credentials
    request = OAuth2::Server::Request.new({
                        :client_id => @client_id,
                        :username => 'blackbeard',
                        :password => '$3Rdj@w',
                        :grant_type => 'password',
                        :state => @state
                        })
    request_handler = OAuth2::Server::RequestHandler.new(request, @config)
    @config[:user_datastore].expects(:authenticate).with('blackbeard', '$3Rdj@w').returns(true)
    @config[:token_datastore].expects(:generate_user_token).with(@mock_user, {}).returns(@token_response)
    assert_equal @token_response, request_handler.access_token_response(@mock_user)
  end

  def test_should_return_throw_error_with_grant_type_refresh_token_and_invalid_refresh_token
    request = OAuth2::Server::Request.new({
                        :client_id => @client_id,
                        :grant_type => 'refresh_token',
                        :refresh_token => "bogus"
                        })
    request_handler = OAuth2::Server::RequestHandler.new(request, @config)
    @config[:token_datastore].expects(:from_refresh_token).with('bogus').returns(nil)
    assert_raises OAuth2::OAuth2Error::InvalidRequest do
      request_handler.access_token_response
    end
  end

  def test_should_return_access_token_with_grant_type_refresh_token_and_valid_refresh_token
    request = OAuth2::Server::Request.new({
                        :client_id => @client_id,
                        :grant_type => 'refresh_token',
                        :refresh_token => @refresh_token
                        })
    request_handler = OAuth2::Server::RequestHandler.new(request, @config)
    @config[:token_datastore].expects(:from_refresh_token).with(@refresh_token).returns(@token_response)
    assert_equal @token_response, request_handler.access_token_response
  end
end