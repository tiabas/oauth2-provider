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
    @token_response = {
                        :access_token => @access_token,
                        :refresh_token => @refresh_token,
                        :token_type => @token_type,
                        :expires_in =>  @expires_in,
                      }
    @request = OAuth2::Server::AbstractRequest.new({
                        :client_id => @client_id,
                        :response_type => 'code',
                        :redirect_uri => 'http://client.example.com/oauth_v2/cb',
                        :state => 'xyz'
                        })
    OAuth2::Server::AbstractRequest.any_instance.stubs(:verify_client_id).returns(true)
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

  def test_should_return_true_with_valid_client_id
    assert_equal true, @request.validate_client_id
  end

  def test_should_raise_invalid_request_error_with_missing_response_type
    request = OAuth2::Server::AbstractRequest.new({
                        :client_id => @client_id,
                        :response_type => nil,
                        :redirect_uri => 'http://client.example.com/oauth_v2/cb',
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
                        :redirect_uri => 'http://client.example.com/oauth_v2/cb',
                        :state => 'xyz'
                        })
    assert_raises OAuth2::OAuth2Error::UnsupportedResponseType do
      request.validate_response_type
    end 
  end

  def test_should_raise_invalid_request_error_with_missing_response_type
    request = OAuth2::Server::AbstractRequest.new({
                        :client_id => @client_id,
                        :grant_type => nil,
                        :redirect_uri => 'http://client.example.com/oauth_v2/cb',
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
                        :redirect_uri => 'http://client.example.com/oauth_v2/cb',
                        :state => 'xyz'
                        })
    assert_raises OAuth2::OAuth2Error::UnsupportedGrantType do
      request.validate_grant_type
    end 
  end

  # def test_authorization_code_grant_should_return_access_token
  #   c = OAuth2::Server::Request.new({
  #                       :client_id => @client_id,
  #                       :grant_type => 'authorization_code',
  #                       :code => @code
  #                       })
  #   assert_equal @token_response, JSON.parse(c.access_token)
  # end
  
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