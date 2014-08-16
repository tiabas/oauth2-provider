class ImplicitTest < MiniTest::Unit::TestCase
  def setup
    @client_id = 's6BhdRkqt3'
    @redirect_uri = 'https://client.example.com/oauth_v2/cb'
    @request = OAuth2Provider::Request.new({
                        :client_id => @client_id,
                        :grant_type => 'token',
                        :redirect_uri => @redirect_uri
                        })
    @token = mock()
    @adapter = mock()
    @adapter.stubs(:generate_access_token).returns(@token)
    @adapter.stubs(:client_id_valid?).returns(true)
  end

  def test_should_return_access_token
    grant = OAuth2Provider::Strategy::Implicit.new(@request, @adapter)
    token = mock()

    @adapter.expects(:generate_access_token).with(@request, {}).returns(token)
    assert_equal token, grant.access_token
  end
end
