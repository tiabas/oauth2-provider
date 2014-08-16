class RequestTest < MiniTest::Unit::TestCase

  def setup
    @code = 'G3Y6jU3a'
    @client_id = 's6BhdRkqt3'
    @client_secret = 'SplxlOBeZQQYbYS6WxSbIA'
    @access_token = '2YotnFZFEjr1zCsicMWpAA'
    @refresh_token = 'tGzv3JOkF0XG5Qx2TlKWIA'
    @expires_in = 3600
    @token_type = 'bearer'
    @redirect_uri = create_redirect_uri
    @token_response = {
                        :access_token => @access_token,
                        :refresh_token => @refresh_token,
                        :token_type => @token_type,
                        :expires_in =>  @expires_in,
                      }
  end

  def test_should_raise_invalid_request_error_with_missing_response_type
    request = OAuth2Provider::Request.new({
                        :client_id => @client_id,
                        :redirect_uri => @redirect_uri,
                        :state => 'xyz'
                        })
    assert_raises OAuth2Provider::Error::InvalidRequest do
      request.validate_response_type!
    end
  end

  def test_should_raise_unsupported_response_type_with_invalid_response_type
    request = OAuth2Provider::Request.new({
                        :client_id => @client_id,
                        :response_type => 'fake',
                        :redirect_uri => @redirect_uri,
                        :state => 'xyz'
                        })
    assert_raises OAuth2Provider::Error::UnsupportedResponseType do
      request.validate_response_type!
    end
  end

  def test_should_raise_invalid_request_error_with_missing_grant_type
    request = OAuth2Provider::Request.new({
                        :client_id => @client_id,
                        :grant_type => nil,
                        :redirect_uri => @redirect_uri,
                        :state => 'xyz'
                        })
    assert_raises OAuth2Provider::Error::InvalidRequest do
      request.validate_grant_type!
    end
  end

  # Authorization code flow
  def test_should_raise_error_with_empty_client_id
    request = OAuth2Provider::Request.new({
                        :client_id => '',
                        :response_type => 'code',
                        :redirect_uri => @redirect_uri,
                        :state => 'xyz'
                        })
    assert_raises OAuth2Provider::Error::InvalidRequest do
      request.validate_client_id!
    end
  end

  def test_should_return_false_with_nil_client_id
    request = OAuth2Provider::Request.new({
                        :client_id => nil,
                        :response_type => 'code',
                        :redirect_uri => @redirect_uri,
                        :state => 'xyz'
                        })
    assert_raises OAuth2Provider::Error::InvalidRequest do
      assert request.validate_client_id!
    end
  end

  def test_should_raise_invalid_request_with_invalid_redirect_uri
    request = OAuth2Provider::Request.new({
                        :client_id => @client_id,
                        :grant_type => 'code',
                        :redirect_uri => 'ftp://client.example2.com/oauth_v2/cb',
                        :state => 'xyz'
                        })
    assert_raises OAuth2Provider::Error::InvalidRequest do
      request.validate_redirect_uri!
    end
  end

  def test_should_raise_unsupported_grant_type_with_invalid_grant_type
    request = OAuth2Provider::Request.new({
                        :client_id => @client_id,
                        :grant_type => 'fake',
                        :redirect_uri => @redirect_uri,
                        :state => 'xyz'
                        })
    assert_raises OAuth2Provider::Error::UnsupportedGrantType do
      request.validate_grant_type!
    end
  end

  # Implicit grant flow
  def test_should_raise_invalid_request_when_response_type_token_and_invalid_redirect_uri
    request = OAuth2Provider::Request.new({
                        :client_id => @client_id,
                        :grant_type => 'token',
                        :redirect_uri => 'ftp://client.example2.com/oauth_v2/cb',
                        :state => 'xyz'
                        })
    assert_raises OAuth2Provider::Error::InvalidRequest do
      request.validate_redirect_uri!
    end
  end

  def test_should_pass_validation_when_response_type_token_and_redirect_uri_nil
    request = OAuth2Provider::Request.new({
                        :client_id => @client_id,
                        :grant_type => 'token',
                        :state => 'xyz'
                        })
    assert true, request.validate_redirect_uri!
  end

  def test_should_pass_validation_when_response_type_code_and_valid_redirect_uri
    request = OAuth2Provider::Request.new({
                        :client_id => @client_id,
                        :grant_type => 'token',
                        :redirect_uri => @redirect_uri,
                        :state => 'xyz'
                        })
    assert request.validate_redirect_uri!
  end
end
