class ConnectionTest < MiniTest::Unit::TestCase

  def setup
    @http_connection = mock()
    @connection = OAuth2::Client::Connection.new('https', 'example.com')
    @connection.stubs(:http_connection).returns(@http_connection)
  end

  def test_should_make_get_request_correct_uri
    # path, params, method, headers
    # should call get on http_connection with constructed URI
    path = '/oauth/authorize'
    params = {:client_id => '001337', :client_secret => 'abcxyz'}
    method = 'get'
    headers = {}
    uri = '/oauth/authorize?client_id=001337&client_secret=abcxyz' 
    @http_connection.expects(:get).with(uri, headers)
    @connection.send_request(path, params, method, {})
  end
end
