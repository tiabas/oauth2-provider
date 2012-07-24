require 'test/unit'
require 'mocha'
require 'oauth2'

class TestOAuth2Request < MiniTest::Unit::TestCase
  
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
    @request = OAuth2::Server::AbstractRequest.new({
                        :client_id => @client_id,
                        :response_type => 'code',
                        :redirect_uri => @redirect_uri,
                        :state => 'xyz'
                        })
    @dummy_client_app = create_client_application
    @dummy_user = create_user
    OAuth2::Server::AbstractRequest.any_instance.stubs(:verify_client_id).returns(@dummy_client_app)
  end
  
  ### TODO:create single request instance for NotImplementedError test
  def test_should_raise_not_implemented_error_with_client_verification_unimplemented
    OAuth2::Server::AbstractRequest.any_instance.unstub(:verify_client_id)
    assert_raises NotImplementedError do
      @request.validate_client_id
    end 
  end
  ###

  def test_should_raise_invalid_request_error_with_invalid_client_id
    OAuth2::Server::AbstractRequest.any_instance.stubs(:verify_client_id).returns(nil)
    assert_raises OAuth2::OAuth2Error::InvalidClient do
      @request.validate_client_id
    end 
  end

  def test_should_return_client_with_valid_client_id
    assert_equal @dummy_client_app, @request.validate_client_id
  end

  def test_should_raise_invalid_request_error_with_missing_response_type
    request = OAuth2::Server::AbstractRequest.new({
                        :client_id => @client_id,
                        :response_type => nil,
                        :redirect_uri => @redirect_uri,
                        :state => 'xyz'
                        })
    assert_raises OAuth2::OAuth2Error::InvalidRequest do
      request.validate_response_type
    end 
  end

  def test_should_raise_unsupported_response_type_with_invalid_response_type
    request = OAuth2::Server::AbstractRequest.new({
                        :client_id => @client_id,
                        :response_type => 'fake',
                        :redirect_uri => @redirect_uri,
                        :state => 'xyz'
                        })
    assert_raises OAuth2::OAuth2Error::UnsupportedResponseType do
      request.validate_response_type
    end 
  end

  def test_should_raise_invalid_request_error_with_missing_grant_type
    request = OAuth2::Server::AbstractRequest.new({
                        :client_id => @client_id,
                        :grant_type => nil,
                        :redirect_uri => @redirect_uri,
                        :state => 'xyz'
                        })
    assert_raises OAuth2::OAuth2Error::InvalidRequest do
      request.validate_grant_type
    end 
  end

  def test_should_raise_unsupported_grant_type_with_invalid_grant_type
    request = OAuth2::Server::AbstractRequest.new({
                        :client_id => @client_id,
                        :grant_type => 'fake',
                        :redirect_uri => @redirect_uri,
                        :state => 'xyz'
                        })
    assert_raises OAuth2::OAuth2Error::UnsupportedGrantType do
      request.validate_grant_type
    end 
  end

  def test_should_return_redirect_uri_when_grant_type_is_authorization_code
    request = OAuth2::Server::AbstractRequest.new({
                        :client_id => @client_id,
                        :grant_type => 'code',
                        :redirect_uri => @redirect_uri,
                        :state => 'xyz'
                        })
    request.expects(:verify_client_id).returns(@dummy_client_app)
    assert_equal @redirect_uri, request.validate_redirect_uri
  end

  def test_should_return_nil_when_response_type_code_and_redirect_uri_nil
    request = OAuth2::Server::AbstractRequest.new({
                        :client_id => @client_id,
                        :grant_type => 'code',
                        :state => 'xyz'
                        })
    assert_equal nil, request.validate_redirect_uri
  end

  def test_should_throw_exception_when_response_type_code_and_redirect_uri_does_not_match
    request = OAuth2::Server::AbstractRequest.new({
                        :client_id => @client_id,
                        :grant_type => 'code',
                        :redirect_uri => 'https://client.example2.com/oauth_v2/cb',
                        :state => 'xyz'
                        })
    request.expects(:verify_client_id).returns(@dummy_client_app)
    assert_raises OAuth2::OAuth2Error::InvalidRequest do
      request.validate_redirect_uri
    end
  end

  def test_should_throw_exception_when_response_type_authorization_code_and_code_nil
    request = OAuth2::Server::AbstractRequest.new({
                        :client_id => @client_id,
                        :grant_type => 'authorization_code',
                        :redirect_uri => 'https://client.example2.com/oauth_v2/cb',
                        :state => 'xyz'
                        })
    OAuth2::Server::AbstractRequest.any_instance.stubs(:verify_client_id).returns(@dummy_client_app)
    assert_raises OAuth2::OAuth2Error::InvalidRequest do
      request.validate_redirect_uri
    end
  end

  def test_should_return_redirect_uri_when_response_type_is_token
    request = OAuth2::Server::AbstractRequest.new({
                        :client_id => @client_id,
                        :grant_type => 'token',
                        :redirect_uri => @redirect_uri,
                        :state => 'xyz'
                        })
    OAuth2::Server::AbstractRequest.any_instance.stubs(:verify_client_id).returns(@dummy_client_app)
    assert_equal @redirect_uri, request.validate_redirect_uri
  end

  def test_should_return_nil_when_response_type_token_and_redirect_uri_nil
    request = OAuth2::Server::AbstractRequest.new({
                        :client_id => @client_id,
                        :grant_type => 'token',
                        :state => 'xyz'
                        })
    OAuth2::Server::AbstractRequest.any_instance.stubs(:verify_client_id).returns(@dummy_client_app)
    assert_equal nil, request.validate_redirect_uri
  end

  def test_should_raise_invalid_request_with_username_and_password_missing_and_grant_type_is_user_credentials
    request = OAuth2::Server::AbstractRequest.new({
                        :client_id => @client_id,
                        :grant_type => 'password',
                        :redirect_uri => @redirect_uri
                        })
    assert_raises OAuth2::OAuth2Error::InvalidRequest do
      request.validate_user_credentials
    end
  end

  def test_should_raise_invalid_request_with_username_missing_and_grant_type_is_user_credentials
    request = OAuth2::Server::AbstractRequest.new({
                        :client_id => @client_id,
                        :grant_type => 'password',
                        :redirect_uri => @redirect_uri,
                        :username => 'benutzername'
                        })
    assert_raises OAuth2::OAuth2Error::InvalidRequest do
      request.validate_user_credentials
    end
  end

  def test_should_raise_invalid_request_with_password_missing_and_grant_type_is_user_credentials
    request = OAuth2::Server::AbstractRequest.new({
                        :client_id => @client_id,
                        :grant_type => 'password',
                        :redirect_uri => @redirect_uri,
                        :password => 'kennwort'
                        })
    assert_raises OAuth2::OAuth2Error::InvalidRequest do
      request.validate_user_credentials
    end
  end

  def test_should_pass_with_correct_username_and_password_missing_and_grant_type_is_user_credentials
    benutzername = 'benutzername'
    kennwort = 'passwort'
    request = OAuth2::Server::AbstractRequest.new({
                        :client_id => @client_id,
                        :grant_type => 'password',
                        :redirect_uri => @redirect_uri,
                        :username => benutzername,
                        :password => kennwort
                        })
    OAuth2::Server::AbstractRequest.any_instance.stubs(:authenticate_user_credentials).with(benutzername, kennwort).returns(@dummy_user)
    assert_equal @dummy_user, request.validate_user_credentials
  end

  def test_should_pass_with_incorrect_username_and_password_missing_and_grant_type_is_user_credentials
    benutzername = 'username'
    kennwort = 'password'
    request = OAuth2::Server::AbstractRequest.new({
                        :client_id => @client_id,
                        :grant_type => 'password',
                        :redirect_uri => @redirect_uri,
                        :username => benutzername,
                        :password => kennwort
                        })
    OAuth2::Server::AbstractRequest.any_instance.stubs(:authenticate_user_credentials).with(benutzername, kennwort).returns(nil)
    assert_raises OAuth2::OAuth2Error::AccessDenied do
      request.validate_user_credentials
    end
  end

  def test_should_raise_invalid_request_with_client_secret_missing_and_grant_type_is_client_credentials
    request = OAuth2::Server::AbstractRequest.new({
                        :client_id => @client_id,
                        :grant_type => 'client_credentials',
                        :redirect_uri => @redirect_uri
                        })
    assert_raises OAuth2::OAuth2Error::InvalidRequest do
      request.validate_client_credentials
    end
  end

  def test_should_raise_unauthorized_client_with_invalid_client_secret_grant_type_is_client_credentials
    request = OAuth2::Server::AbstractRequest.new({
                        :client_id => @client_id,
                        :grant_type => 'client_credentials',
                        :redirect_uri => @redirect_uri,
                        :client_secret => @client_secret
                        })
    OAuth2::Server::AbstractRequest.any_instance.stubs(:authenticate_client_credentials).returns(false)
    assert_raises OAuth2::OAuth2Error::UnauthorizedClient do
      request.validate_client_credentials
    end
  end

  def test_should_pass_with_valid_client_secret_grant_type_is_client_credentials
    request = OAuth2::Server::AbstractRequest.new({
                        :client_id => @client_id,
                        :grant_type => 'client_credentials',
                        :redirect_uri => @redirect_uri,
                        :client_secret => @client_secret
                        })
    OAuth2::Server::AbstractRequest.any_instance.stubs(:authenticate_client_credentials).returns(true)
    assert request.validate_client_credentials
  end

  def test_should_raise_invalid_request_with_grant_type_client_credentials_but_no_code
    request = OAuth2::Server::AbstractRequest.new({
                        :client_id => @client_id,
                        :grant_type => 'authorization_code',
                        :redirect_uri => @redirect_uri,
                        })
    assert_raises OAuth2::OAuth2Error::InvalidRequest do
      request.validate_authorization_code
    end
  end

  def test_should_raise_unauthorized_client_with_grant_type_client_credentials_and_invalid_code
    request = OAuth2::Server::AbstractRequest.new({
                        :client_id => @client_id,
                        :grant_type => 'authorization_code',
                        :redirect_uri => @redirect_uri,
                        :code => @code
                        })
    request.expects(:verify_authorization_code).returns(false)
      assert_raises OAuth2::OAuth2Error::UnauthorizedClient do
      request.validate_authorization_code
    end
  end

  def test_should_pass_with_grant_type_client_credentials_and_valid_code
    request = OAuth2::Server::AbstractRequest.new({
                        :client_id => @client_id,
                        :grant_type => 'authorization_code',
                        :redirect_uri => @redirect_uri,
                        :code => @code
                        })
    request.expects(:verify_authorization_code).returns(true)
    assert_equal true, request.validate_authorization_code
  end

  def test_should_raise_invalid_request_with_grant_type_refresh_token_but_no_refresh_token
    request = OAuth2::Server::AbstractRequest.new({
                        :client_id => @client_id,
                        :grant_type => 'refresh_token',
                        })
    assert_raises OAuth2::OAuth2Error::InvalidRequest do
      request.validate_refresh_token
    end
  end

  def test_should_pass_with_grant_type_refresh_token_and_refresh_token
    request = OAuth2::Server::AbstractRequest.new({
                        :client_id => @client_id,
                        :grant_type => 'refresh_token',
                        :refresh_token => @refresh_token
                        })
    assert request.validate_refresh_token
  end
  
  # def test_implicit_grant_authorization_request_should_return_access_token
  #   c = OAuth2::Server::Request.new({
  #                       :client_id => @client_id,
  #                       :response_type => 'token',
  #                       :redirect_uri => 'http://client.example.com/oauth_v2/cb',
  #                       :state => 'xyz',
  #                       })
  #   # should stub request#access_token
  #   redirect_uri = 'http://example.com/cb#access_token=2YotnFZFEjr1zCsicMWpAA&state=xyz&token_type=example&expires_in=3600'
  #   assert_equal redirect_uri, c.access_token_redirect_uri
  # end

  # def test_resource_owner_credentials_should_return_access_token
  #   c = OAuth2::Server::Request.new({
  #                       :client_id => @client_id,
  #                       :grant_type => 'password',
  #                       :username => 'johndoe',
  #                       :password => 'A3ddj3w'
  #                       })
  #   # should stub request#access_token
  #   assert_equal @token_response, JSON.parse(c.access_token)
  # end
  
  # def test_client_credentials_should_return_access_token
  #   c = OAuth2::Server::Request.new({
  #                       :client_id => @client_id,
  #                       :client_secret => @client_secret,
  #                       :grant_type => 'client_credentials'
  #                       })
  #   # should stub request#access_token
  #   assert_equal @token_response, JSON.parse(c.access_token)
  # end

  # def test_refresh_token_request_should_return_access_token
  #   c = OAuth2::Server::Request.new({
  #                       :client_id => @client_id,
  #                       :grant_type => 'refresh_token',
  #                       :refresh_token => @refresh_token
  #                       })
  #   # should stub request#access_token
  #   assert_equal @token_response, JSON.parse(c.access_token)
  # end
end