# class AuthorizationCodeTest < MiniTest::Unit::TestCase
#   def setup
#     @code = 'G3Y6jU3a'
#     @client_id = 's6BhdRkqt3'
#     @client_secret = 'SplxlOBeZQQYbYS6WxSbIA'
#     @access_token = '2YotnFZFEjr1zCsicMWpAA'
#     @refresh_token = 'tGzv3JOkF0XG5Qx2TlKWIA'
#     @expires_in = 3600
#     @state = 'xyz'
#     @scope = "scope1 scope2"
#     @token_type = 'Bearer'
#     @redirect_uri = 'https://client.example.com/oauth_v2/cb'
#     @client_app = mock()
#     @client_app.stubs(:redirect_uri).returns(@redirect_uri)

#     @config = mock()
#   end

#   # Authorization redirect URI
#   def test_should_raise_invalid_client
#     request = OAuth2Provider::Request.new({
#                         :client_id => @client_id,
#                         :response_type => 'code',
#                         :redirect_uri => @redirect_uri,
#                         :state => @state,
#                         :scope => @scope
#                         })
#     @config.client_datastore.stubs(:find_client_with_id).returns(nil)
#     request_handler = OAuth2Provider::Strategy::AuthorizationCode.new(request)
    
#     assert_raises OAuth2Provider::Error::InvalidClient do
#       request_handler.authorization_code(@mock_user)
#     end
#   end

#   def test_should_return_authorization_code
#     request = OAuth2Provider::Request.new({
#                         :client_id => @client_id,
#                         :response_type => 'code',
#                         :redirect_uri => @redirect_uri,
#                         :state => @state,
#                         :scope => @scope
#                         })
#     @config.code_datastore.expects(:generate_authorization_code).returns(@code)
#     @client_app.expects(:validate_redirect_uri).returns(true)

#     strategy = OAuth2Provider::Strategy::AuthorizationCode.new(request)

#     assert_equal @code, strategy.authorization_code(@mock_user)
#   end

#   def test_should_return_authorization_code_redirect_uri
#     request = OAuth2Provider::Request.new({
#                         :client_id => @client_id,
#                         :response_type => 'code',
#                         :redirect_uri => @redirect_uri,
#                         :state => @state,
#                         :scope => @scope
#                         })
#     @config.code_datastore.expects(:generate_authorization_code).returns(@code)
#     @client_app.expects(:validate_redirect_uri).returns(true)

#     strategy = OAuth2Provider::Strategy::AuthorizationCode.new(request)
#     redirect_uri = "#{@redirect_uri}?code=#{@code}&state=#{@state}"

#     assert_equal redirect_uri, strategy.authorization_redirect_uri(@mock_user)
#   end

#   def test_should_raise_unsupported_response_type
#     request = OAuth2Provider::Request.new({
#                         :client_id => @client_id,
#                         :response_type => 'code',
#                         :redirect_uri => @redirect_uri,
#                         :state => @state,
#                         :scope => @scope
#                         })
#     strategy = OAuth2Provider::Strategy::AuthorizationCode.new(request)
    
#     assert_raises OAuth2Provider::Error::InvalidRequest do
#       strategy.access_token @mock_user
#     end
#   end

#   def test_should_raise_error_with_invalid_authorization_code
#     request = OAuth2Provider::Request.new({
#                         :client_id => @client_id,
#                         :grant_type => 'authorization_code',
#                         :redirect_uri => @redirect_uri,
#                         :code => '7xI4fk3Z',
#                         :state => @state,
#                         :scope => @scope
#                         })

#     @client_app.stubs(:validate_redirect_uri).returns(true)

#     @config.code_datastore.expects(:verify).with(
#         :client => @client_app, 
#         :code => '7xI4fk3Z', 
#         :redirect_uri => @redirect_uri).returns(nil)

#     strategy = OAuth2Provider::Strategy::AuthorizationCode.new(request)

#     assert_raises OAuth2Provider::Error::InvalidGrant do
#       strategy.access_token @mock_user
#     end
#   end

#   def test_should_raise_invalid_request_when_nil_authorization_code
#     request = OAuth2Provider::Request.new({
#                         :client_id => @client_id,
#                         :grant_type => 'authorization_code',
#                         :redirect_uri => @redirect_uri,
#                         :state => @state,
#                         :scope => @scope
#                         })
#     strategy = OAuth2Provider::Strategy::AuthorizationCode.new(request)
#     @client_app.stubs(:validate_redirect_uri).returns(true)
#     assert_raises OAuth2Provider::Error::InvalidRequest do
#       strategy.access_token
#     end
#   end

#   def test_should_return_access_token
#     request = OAuth2Provider::Request.new({
#                         :client_id => @client_id,
#                         :grant_type => 'authorization_code',
#                         :redirect_uri => @redirect_uri,
#                         :code => @code,
#                         :state => @state,
#                         :scope => @scope
#                         })
#     strategy = OAuth2Provider::Strategy::AuthorizationCode.new(request)
#     token = {
#       :access_token => @access_token,
#       :refresh_token => @refresh_token,
#       :token_type => @token_type,
#       :expires_in =>  @expires_in,
#     }

#     @client_app.stubs(:validate_redirect_uri).returns(true)


#     mock_user = mock()

#     auth_code = mock()
#     auth_code.expects(:user).returns(mock_user)
#     auth_code.expects(:expired?).returns(false)
#     auth_code.expects(:deactivated?).returns(false)

#     @config.code_datastore.expects(:verify).with(        
#         :client => @client_app, 
#         :code => @code, 
#         :redirect_uri => @redirect_uri).returns(auth_code)
#     @config.token_datastore.expects(:generate_token).with(:client => @client_app, :user => mock_user, :scope => 'scope1 scope2').returns(token)
    
#     assert_equal token, strategy.access_token
#   end
# end
