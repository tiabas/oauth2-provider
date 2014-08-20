require 'test/unit'
require 'mocha/test_unit'
require 'oauth2-provider'

require 'request_test'
require 'grant/implicit_test'
require 'grant/client_credentials_test'
require 'grant/password_test'
require 'grant/refresh_token_test'
require 'grant/authorization_code_test'

TEST_ROOT = File.dirname(__FILE__)

class Test::Unit::TestCase
  def create_redirect_uri
    'https://client.example.com/oauth_v2/cb'
  end
end
