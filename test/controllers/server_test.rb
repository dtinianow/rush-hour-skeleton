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

end
