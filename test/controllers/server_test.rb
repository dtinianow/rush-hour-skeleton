require './test/test_helper'

class RushHourAppTest < Minitest::Test
  include Rack::Test::Methods, TestHelpers, DataProcessor

  def app
    RushHour::Server
  end

  def test_create_a_new_client_with_valid_attributes
    post '/sources', { identifier: 'jumpstart', rootUrl:'http://jumpstartlab.com' }
    assert_equal 200, last_response.status
    assert_equal "{'identifier':'jumpstart'}", last_response.body
  end

  def test_cannot_create_a_client_with_missing_attributes
    post '/sources', { identifier: 'jumpstart'}
    assert_equal 400, last_response.status
    post '/sources', { rootUrl: 'http://jumpstartlab.com'}
    assert_equal 400, last_response.status
    assert_equal "Identifier can't be blank", last_response.body
  end

  def test_cannot_create_new_client_with_already_existing_identifier
    Client.create( {identifier: 'jumpstart', root_url: 'http://jumpstartlab.com'} )
    post '/sources', { identifier: 'jumpstart', rootUrl: 'http://jumpstartlab.com' }
    assert_equal 403, last_response.status
    assert_equal "Identifier 'jumpstart' already exists", last_response.body
  end

  def test_responds_with_400_status_if_payload_is_missing
    Client.create( {identifier: 'jumpstart', root_url: 'http://jumpstartlab.com'} )
    post '/sources/jumpstart/data'
    assert_equal 400, last_response.status
    assert_equal "Payload missing - a payload is required", last_response.body
  end

  def test_responds_with_403_status_if_payload_already_exists
    Client.create( {identifier: 'jumpstart', root_url: 'http://jumpstartlab.com'} )
    process_payload(raw_data)
    post '/sources/jumpstart/data', {payload: raw_data}
    assert_equal 403, last_response.status
    assert_equal "Record with the supplied payload already exists", last_response.body
  end

  def test_responds_with_403_status_if_client_is_not_yet_created
    post '/sources/jumpstart/data', {payload: raw_data}
    assert_equal 403, last_response.status
  end

  def test_responds_with_200_status_when_unique_payload_and_existing_client
    Client.create( {identifier: 'jumpstart', root_url: 'http://jumpstartlab.com'} )
    post '/sources/jumpstart/data', {payload: raw_data}
    assert_equal 200, last_response.status
    assert_equal 'Payload entered into database', last_response.body
  end

  def test_responds_with_index_if_client_exists_and_payload_is_registered
    Client.create( {identifier: 'jumpstartlab', root_url: 'http://jumpstartlab.com'} )
    data = process_foreign_tables(raw_data)
    data[:client_id] = 1
    PayloadRequest.create(data)
    get '/sources/jumpstartlab'
    assert_equal 200, last_response.status
    assert last_response.body.include?("Data for 'jumpstartlab'")
  end

  def test_responds_with_error_message_if_client_does_not_exist
    get '/sources/jumpstartlab'
    assert_equal 200, last_response.status
    assert last_response.body.include?('jumpstartlab does not exist')
  end

  def test_responds_with_error_message_if_no_payload_is_registered_for_client
    Client.create( {identifier: 'jumpstartlab', root_url: 'http://jumpstartlab.com'} )
    get '/sources/jumpstartlab'
    assert_equal 200, last_response.status
    assert last_response.body.include?('No payload registered for jumpstart')
  end

  def test_responds_with_error_message_if_no_path_exists_for_identifier
    Client.create( {identifier: 'jumpstartlab', root_url: 'http://jumpstartlab.com'} )
    get '/sources/jumpstartlab/urls/nothing'
    assert_equal 200, last_response.status
    assert last_response.body.include?("The path 'nothing' for 'jumpstartlab' has not been requested.")
  end

  def test_responds_with_relative_path_page_if_path_exists_for_identifier
    Client.create( {identifier: 'jumpstartlab', root_url: 'http://jumpstartlab.com'} )
    data = process_foreign_tables(raw_data)
    data[:client_id] = 1
    PayloadRequest.create(data)
    get '/sources/jumpstartlab/urls/blog'
    assert_equal 200, last_response.status
    assert last_response.body.include?('Max. response time for this URL:')
  end

end
