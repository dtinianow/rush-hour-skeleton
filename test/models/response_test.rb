require './test/test_helper'

class ResponseTest < Minitest::Test
  include TestHelpers, Response, DataProcessor

  def test_it_sets_appropriate_status_and_message_based_on_client
    client = Client.create(identifier: 'google', root_url: 'http://google.com')

    expected = {status: 403, body: "Identifier 'google' already exists"}
    assert_equal expected, process_client(client, 'google')

    client_1 = Client.new(identifier: 'jumstartlab', root_url: 'http://jumpstartlab.com')

    expected = {status: 200, body: "{'identifier':'jumpstartlab'}"}
    assert_equal expected, process_client(client_1, 'jumpstartlab')

    client_2 = Client.new(identifier: 'bing')

    expected = {status: 400, body: "Root url can't be blank"}
    assert_equal expected, process_client(client_2, 'bing')
  end

  def test_it_sets_appropriate_status_and_message_based_on_payload
    expected = {status: 403, body: "Client with identifier 'google' is not yet registered."}
    assert_equal expected, process_client_payload(Client.find_by(identifier: 'google'), 'google', raw_data)

    populate_client_payload
    expected = {status: 200, body: "Payload entered into database"}
    assert_equal expected, process_client_payload(Client.first, 'jumpstartlab', raw_data)

    expected = {status: 400, body: "Payload missing - a payload is required"}
    assert_equal expected, process_client_payload(Client.first, 'jumpstartlab', nil)

    expected = {status: 403, body: 'Record with the supplied payload already exists'}
    assert_equal expected, process_client_payload(Client.first, 'jumpstartlab', raw_data)
  end

end
