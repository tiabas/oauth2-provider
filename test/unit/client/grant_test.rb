class GrantTest < MiniTest::Unit::TestCase

  def setup
    @client_id      = 's6BhdRkqt3'
    @client_secret  = 'SplxlOBeZQQYbYS6WxSbIA'
    @authorize_path = "/oauth/authorize"
    @token_path     = "/oauth/token"
    @client = mock()
    @client.stubs(:client_id).returns(@client_id)
    @client.stubs(:client_secret).returns(@client_secret)
    @client.stubs(:authorize_path).returns(@authorize_path)
    @client.stubs(:token_path).returns(@token_path)  
  end

  # def test_attempt_to_initialize_base_grant
  #   assert_raises NoMethodError do
  #     grant = OAuth2::Client::Grant::Base.new
  #   end
  # end

  def test_nil_parameters_should_be_ignored

    grant = OAuth2::Client::Grant::Password.new(@client, 'johndoe', 'password',
                                                :password => nil,
                                                :scope => nil)
    result = {
      :client_id => @client_id,
      :client_secret => @client_secret,
      :grant_type => 'password',
      :username => 'johndoe',
      :password => 'password'
    }
    assert_equal result, grant
  end

  def test_optional_parameters_should_not_overwrite_required_parameters

    grant = OAuth2::Client::Grant::Password.new(@client, 'johndoe', 'password',
                                                :password => 'overwrite',
                                                :scope => 'xyz')
    result = {
      :client_id => @client_id,
      :client_secret => @client_secret,
      :grant_type => 'password',
      :username => 'johndoe',
      :password => 'password',
      :scope => 'xyz'
    }
    assert_equal result, grant
  end

  def test_create_password_grant
    grant = OAuth2::Client::Grant::Password.new(@client, 'johndoe', 'password')
    result = {
      :client_id => @client_id,
      :client_secret => @client_secret,
      :grant_type => 'password',
      :username => 'johndoe',
      :password => 'password'
    }
    assert_equal result, grant
  end

  def test_password_grant_token_request
    grant = OAuth2::Client::Grant::Password.new(@client, 'johndoe', 'password', :scope => 'xyz')
    params = {
      :client_id => @client_id,
      :client_secret => @client_secret,
      :grant_type => 'password',
      :username => 'johndoe',
      :password => 'password',
      :scope => 'xyz'
    }
    @client.expects(:make_request).with(@token_path, params, 'post', {}).returns(true)
    grant.get_token
  end

  def test_create_refresh_token_grant
    grant = OAuth2::Client::Grant::RefreshToken.new(@client, '2YotnFZFEjr1zCsicMWpAA')
    result = {
      :client_id => @client_id,
      :client_secret => @client_secret,
      :refresh_token => '2YotnFZFEjr1zCsicMWpAA',
      :grant_type => 'refresh_token',
      :scope => 'xyz'
    }
    assert_equal result, grant
  end

  def test_create_refresh_token_grant
    grant = OAuth2::Client::Grant::RefreshToken.new(@client, '2YotnFZFEjr1zCsicMWpAA', :scope => 'xyz')
    params = {
      :client_id => @client_id,
      :client_secret => @client_secret,
      :refresh_token => '2YotnFZFEjr1zCsicMWpAA',
      :grant_type => 'refresh_token',
      :scope => 'xyz'
    }
    @client.expects(:make_request).with(@token_path, params, 'post', {}).returns(true)
    grant.get_token
  end

  def test_create_client_credentials_grant
    grant = OAuth2::Client::Grant::ClientCredentials.new(@client)
    result = {
      :client_id => @client_id,
      :client_secret => @client_secret,
      :grant_type => 'client_credentials'
    }
    assert_equal result, grant
  end

  def test_create_authorization_code_grant
    grant = OAuth2::Client::Grant::AuthorizationCode.new(@client, 'G3Y6jU3a', :scope => 'xyz')
    result = {
      :client_id => @client_id,
      :client_secret => @client_secret,
      :code => 'G3Y6jU3a',
      :grant_type => 'authorization_code',
      :scope => 'xyz'
    }
    assert_equal result, grant
  end

  def test_create_implicit_grant
    grant = OAuth2::Client::Grant::Implicit.new(@client, 'code')
    result = {
      :client_id => @client_id,
      :client_secret => @client_secret,
      :response_type => 'code'
    }
    assert_equal result, grant
  end

  def test_create_implicit_grant
    grant = OAuth2::Client::Grant::Implicit.new(@client, 'token')
    result = {
      :client_id => @client_id,
      :client_secret => @client_secret,
      :response_type => 'token'
    }
    assert_equal result, grant
  end
end