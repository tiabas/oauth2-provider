class RefreshTokenTest < MiniTest::Unit::TestCase
  def setup
    @client_id = 's6BhdRkqt3'
    @client_secret = 'SplxlOBeZQQYbYS6WxSbIA'
    @refresh_token = 'tGzv3JOkF0XG5Qx2TlKWIA'
    @adapter = mock
    @adapter.stubs(:client_id_valid?).returns(true)
  end

  # Grant type: refresh_token
  def test_validate_with_missing_refresh_token
    request = OAuth2Provider::Request.new(
                    client_id: @client_id,
                    grant_type: 'refresh_token'
                )
    grant = OAuth2Provider::Strategy::RefreshToken.new(request, @adapter)
    exception = assert_raises OAuth2Provider::Error::InvalidGrant do
      grant.validate!
    end
    assert_equal 'refresh token required', exception.message
  end

  def test_validate_with_invalid_refresh_token
    request = OAuth2Provider::Request.new(
                    client_id: @client_id,
                    grant_type: 'refresh_token',
                    refresh_token: @refresh_token
                )
    grant = OAuth2Provider::Strategy::RefreshToken.new(request, @adapter)
    @adapter.stubs(:refresh_token_valid?).returns(false)
    exception = assert_raises OAuth2Provider::Error::InvalidGrant do
      grant.validate!
    end
    assert_equal 'invalid refresh token', exception.message
  end

  def test_access_token
    request = OAuth2Provider::Request.new(
                    client_id: @client_id,
                    grant_type: 'refresh_token',
                    refresh_token: @refresh_token
                )
    grant = OAuth2Provider::Strategy::RefreshToken.new(request, @adapter)
    token = mock

    @adapter.expects(:token_from_refresh_token).with(request, {}).returns(token)
    assert_equal token, grant.access_token
  end
end
