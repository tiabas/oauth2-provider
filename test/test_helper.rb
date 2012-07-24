require 'unit/server/test_abstract_request'

class MiniTest::Unit::TestCase
  def create_redirect_uri
    return 'https://client.example.com/oauth_v2/cb'
  end

  def create_client_application
    client = Object.new
    (class << client; self; end).class_eval do
      define_method(:redirect_uri) { 'https://client.example.com/oauth_v2/cb' }
      define_method(:authenticate) {|secret| true }
    end
    client
  end
end