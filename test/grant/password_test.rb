class PasswordTest < Test::Unit::TestCase
  def setup
    @client_id = 's6BhdRkqt3'
    @adapter = mock()
    @adapter.stubs(:client_id_valid?).returns(true)
  end

  # Grant type: password
  def test_missing_username_and_password
    request = OAuth2Provider::Request.new(
                      client_id: @client_id,
                      grant_type: 'password'
                      )
    grant = OAuth2Provider::Strategy::Password.new(request, @adapter)
    exception = assert_raises OAuth2Provider::Error::InvalidGrant do
      grant.validate!
    end
    assert_equal 'username required, password required', exception.message
  end

  def test_missing_username
    request = OAuth2Provider::Request.new(
                      client_id: @client_id,
                      grant_type: 'password',
                      password: 'kennwort'
                      )
    grant = OAuth2Provider::Strategy::Password.new(request, @adapter)
    exception = assert_raises OAuth2Provider::Error::InvalidGrant do
      grant.validate!
    end
    assert_equal 'username required', exception.message
  end

  def test_missing_password
    request = OAuth2Provider::Request.new(
                     client_id: @client_id,
                     grant_type: 'password',
                     username: 'benutzername'
                     )
    grant = OAuth2Provider::Strategy::Password.new(request, @adapter)
    exception = assert_raises OAuth2Provider::Error::InvalidGrant do
      grant.validate!
    end
    assert_equal 'password required', exception.message
 end

  def test_invalid_username_and_password
    request = OAuth2Provider::Request.new(
                      client_id: @client_id,
                      grant_type: 'password',
                      username: 'user',
                      password: 'pass'
                      )
    grant = OAuth2Provider::Strategy::Password.new(request, @adapter)

    @adapter.stubs(:resource_owner_credentials_valid?).returns(false)
    exception = assert_raises OAuth2Provider::Error::AccessDenied do
      grant.validate!
    end
    assert_equal 'invalid resource owner credentials', exception.message
  end

  def test_valid_username_and_password
    request = OAuth2Provider::Request.new(
                        client_id: @client_id,
                        grant_type: 'password',
                        username: 'benutzername',
                        password: 'kennwort'
                        )
    grant = OAuth2Provider::Strategy::Password.new(request, @adapter)
    token = mock()

    @adapter.stubs(:resource_owner_credentials_valid?).with(request).returns(true)
    @adapter.expects(:generate_access_token).with(request, {}).returns(token)

    assert_equal token, grant.access_token
    end
end
