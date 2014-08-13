class ImplicitGrantTest < MiniTest::Unit::TestCase
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
                        :grant_type => 'token',
                        :redirect_uri => @redirect_uri,
                        :state => @state
                        })
    @token = mock()
    @adapter = mock()
    @adapter.stubs(:generate_access_token).returns(@token)
  end

  def test_should_return_access_token
    grant = OAuth2Provider::Strategy::Implicit.new(@request, @adapter)
    @adapter.expects(:generate_access_token).with(@request, {})
    grant.access_token
  end
end