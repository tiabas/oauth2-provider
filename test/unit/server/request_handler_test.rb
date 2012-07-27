require 'test/unit'
require 'mocha'
require 'oauth2'

class TestOAuth2RequestHandler < MiniTest::Unit::TestCase
  
  module DummyClasses
    class UserDatastore; end

    class ClientDatastore; end  

    class CodeDatastore; end

    class TokenDatastore; end
  end
  include DummyClasses

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

    @config = {
      :user_datastore => UserDatastore,
      :client_datastore => ClientDatastore,
      :code_datastore => CodeDatastore,
      :token_datastore => TokenDatastore
    } 
  end
  # Authorization Code Flow

  # Authorization redirect URI
  def test_should_raise_invalid_client_with_response_type_code_and_invalid_client_id
    request = OAuth2::Server::Request.new({
                        :client_id => @client_id,
                        :response_type => 'code',
                        :redirect_uri => 'https://client.example2.com/oauth_v2/cb',
                        :state => 'xyz'
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
                        :redirect_uri => 'https://client.example2.com/oauth_v2/cb',
                        :state => 'xyz'
                        })
    @config[:client_datastore].stubs(:find_client_with_id).returns(Object.new)
    @config[:code_datastore].stubs(:generate_authorization_code).returns(@code)
    request_handler = OAuth2::Server::RequestHandler.new(request, @config)
    assert_equal @code, request_handler.fetch_authorization_code
  end

  # def test_should_raise_invalid_request_error_with_invalid_client_id
  #   OAuth2::Server::AbstractRequest.any_instance.stubs(:verify_client_id).returns(nil)
  #   assert_raises OAuth2::OAuth2Error::InvalidClient do
  #     @request.validate_client_id
  #   end 
  # end

  # def test_should_raise_unauthorized_client_with_invalid_client_secret_grant_type_is_client_credentials
  #   request = OAuth2::Server::AbstractRequest.new({
  #                       :client_id => @client_id,
  #                       :grant_type => 'client_credentials',
  #                       :redirect_uri => @redirect_uri,
  #                       :client_secret => @client_secret
  #                       })
  #   OAuth2::Server::AbstractRequest.any_instance.stubs(:authenticate_client_credentials).returns(false)
  #   assert_raises OAuth2::OAuth2Error::UnauthorizedClient do
  #     request.validate_client_credentials
  #   end
  # end

  # def test_should_raise_unauthorized_client_with_grant_type_client_credentials_and_invalid_code
  #   request = OAuth2::Server::AbstractRequest.new({
  #                       :client_id => @client_id,
  #                       :grant_type => 'authorization_code',
  #                       :redirect_uri => @redirect_uri,
  #                       :code => @code
  #                       })
  #   request.expects(:verify_authorization_code).returns(false)
  #     assert_raises OAuth2::OAuth2Error::UnauthorizedClient do
  #     request.validate_authorization_code
  #   end
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