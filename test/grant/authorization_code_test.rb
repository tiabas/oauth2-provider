class AuthorizationCodeTest < Test::Unit::TestCase
  def setup
    @code = 'G3Y6jU3a'
    @client_id = 's6BhdRkqt3'
    @client_secret = 'SplxlOBeZQQYbYS6WxSbIA'
    @state = 'xyz'
    @scope = "scope1 scope2"
    @redirect_uri = 'https://client.example.com/oauth_v2/cb'
    @adapter = mock()
  end

  def test_invalid_authorization_code
    request = OAuth2Provider::Request.new({
                        :client_id => @client_id,
                        :grant_type => 'authorization_code',
                        :redirect_uri => @redirect_uri,
                        :code => '7xI4fk3Z',
                        :state => @state,
                        :scope => @scope
                        })
    grant = OAuth2Provider::Strategy::AuthorizationCode.new(request, @adapter)
    @adapter.stubs(:authorization_code_valid?).returns(false)

    assert_raises OAuth2Provider::Error::InvalidGrant do
        grant.validate!
    end
  end

  def test_invalid_redirect_uri
    request = OAuth2Provider::Request.new({
                    :client_id => @client_id,
                    :grant_type => 'authorization_code',
                    :redirect_uri => @redirect_uri,
                    :state => @state,
                    :scope => @scope
                })
    grant = OAuth2Provider::Strategy::AuthorizationCode.new(request, @adapter)
    @adapter.stubs(:authorization_code_valid?).returns(true)

    @adapter.stubs(:redirect_uri_valid?).returns(false)

    assert_raises OAuth2Provider::Error::InvalidGrant do
        grant.validate!
    end
  end

  def test_generate_access_token
    request = OAuth2Provider::Request.new({
                    :client_id => @client_id,
                    :grant_type => 'authorization_code',
                    :redirect_uri => @redirect_uri,
                    :code => @code,
                    :state => @state,
                    :scope => @scope
                })
    grant = OAuth2Provider::Strategy::AuthorizationCode.new(request, @adapter)
    token = mock()
    @adapter.stubs(:token_from_authorization_code).returns(token)
    assert_equal token, grant.access_token
  end
end