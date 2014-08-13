require 'test/unit'
require 'mocha'
require 'oauth2-provider'

TEST_ROOT = File.dirname(__FILE__)

class MiniTest::Unit::TestCase
  def create_redirect_uri
    return 'https://client.example.com/oauth_v2/cb'
  end
end

require 'request_test'
require 'strategy/implicit_grant_test'
require 'strategy/client_credentials_test'

# require 'unit/server/request_handler_test'