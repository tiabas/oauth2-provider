# class BaseTest < MiniTest::Unit::TestCase
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
#     @token = mock()
#     @token_response = {
#       :access_token => @access_token,
#       :refresh_token => @refresh_token,
#       :token_type => @token_type,
#       :expires_in =>  @expires_in,
#     }
#     @token.stubs(:to_hash).returns(@token_response)
#   end
# end
