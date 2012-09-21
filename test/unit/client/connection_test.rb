class ConnectionTest < MiniTest::Unit::TestCase

  def build_mock_response(status, headers, body)
    response = mock()
    response.stubs(:status).returns(status)
    response.stubs(:body).returns(body)
    response.stubs(:headers).returns(headers)
    response
  end

  def setup
    @http_connection = mock()
    @connection = OAuth2::Client::Connection.new('https', 'example.com')
    @connection.stubs(:http_connection).returns(@http_connection)
    @mock_response = build_mock_response(200, {'Content-Type' => 'text/plain'}, 'success') 
  end

  def test_should_make_successfull_get_request
    path = '/oauth/authorize'
    params = {:client_id => '001337', :client_secret => 'abcxyz'}
    method = 'get'
    headers = {}
    uri = '/oauth/authorize?client_id=001337&client_secret=abcxyz'

    @http_connection.expects(:get).with(uri, headers).returns(@mock_response)
    response = @connection.send_request(path, params, method, {})

    assert_equal 200, response.status
    assert_equal 'success', response.body
    assert_equal ({'Content-Type' => 'text/plain'}), response.headers
  end

  def test_should_make_successfull_delete_request
    path = '/users/1'
    params = {}
    method = 'delete'
    headers = {}
    uri = '/users/1'
 
    @http_connection.expects(:delete).with(uri, params, headers).returns(@mock_response)
    response = @connection.send_request(path, params, method, {})

    assert_equal 200, response.status
    assert_equal 'success', response.body
    assert_equal ({'Content-Type' => 'text/plain'}), response.headers
  end

  def test_should_make_successfull_post_request
    path = '/users'
    params = {:first_name => 'john', :last_name => 'smith'}
    method = 'post'
    headers = {}
    uri = '/users'

    @http_connection.expects(:post).with(uri, params, headers).returns(@mock_response)
    response = @connection.send_request(path, params, method, {})

    assert_equal 200, response.status
    assert_equal 'success', response.body
    assert_equal ({'Content-Type' => 'text/plain'}), response.headers
  end

  def test_should_make_successfull_put_request
    path = '/users/1'
    params = {:first_name => 'jane', :last_name => 'doe'}
    method = 'put'
    headers = {}
    uri = '/users/1'

    @http_connection.expects(:put).with(uri, params, headers).returns(@mock_response)
    response = @connection.send_request(path, params, method, {})

    assert_equal 200, response.status
    assert_equal 'success', response.body
    assert_equal ({'Content-Type' => 'text/plain'}), response.headers
  end
end
