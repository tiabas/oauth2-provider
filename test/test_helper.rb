require 'unit/server/request_test'
require 'unit/server/request_handler_test'

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

  def create_user
    user = Object.new
    (class << user; self; end).class_eval do
      define_method(:authenticate) {|username, password| true }
    end
    user
  end
end