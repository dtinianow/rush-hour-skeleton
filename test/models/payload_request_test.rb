require_relative '../test_helper.rb'

class PayloadRequestTest < Minitest::Test
  include TestHelpers, DataProcessor

  def test_it_parses_the_payload
    payload_request = JSON.parse('{
              "url": "http://jumpstartlab.com/blog",
              "requestedAt": "2013-02-16 21:38:28 -0700",
              "respondedIn": 37,
              "referredBy": "http://jumpstartlab.com",
              "requestType": "GET",
              "userAgent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1309.0 Safari/537.17",
              "resolutionWidth": "1920",
              "resolutionHeight": "1280",
              "ip": "63.29.38.211"
              }')
    assert_equal "63.29.38.211", payload_request["ip"]
    assert_equal 37, payload_request["respondedIn"]
  end

  def test_database_starts_clean
    assert PayloadRequest.all.empty?
    payload_request = process_payload(raw_data)
    assert_equal 37, payload_request.responded_in
    assert payload_request.valid?
    refute PayloadRequest.all.empty?
  end

  def test_it_can_appropriately_process_data_for_columns
    payload_request = process_payload(raw_data)
    assert_equal 37, payload_request.responded_in
  end

  def test_it_can_hold_attributes
    date_time = DateTime.new
    payload_request = PayloadRequest.create(requested_at: date_time, responded_in: 30, url_id: 1, referred_by_id: 2, request_type_id: 3, u_agent_id: 4, resolution_id: 5, ip_id: 6)

    assert_equal date_time, payload_request.requested_at
    assert_equal 30, payload_request.responded_in
    assert_equal 1, payload_request.url_id
    assert_equal 2, payload_request.referred_by_id
    assert_equal 3, payload_request.request_type_id
    assert_equal 4, payload_request.u_agent_id
    assert_equal 5, payload_request.resolution_id
    assert_equal 6, payload_request.ip_id
  end

  def test_average_response_time_across_all_requests
    process_payload(data_3)
    process_payload(data_2)
    assert_equal 58.0, PayloadRequest.average_response_time
  end

  def test_max_response_time_across_all_requests
    process_payload(data_1)
    process_payload(data_2)
    assert_equal 50.0, PayloadRequest.max_response_time
  end

  def test_min_response_time_across_all_requests
    process_payload(data_1)
    process_payload(data_2)
    assert_equal 37.0, PayloadRequest.min_response_time
  end

  def test_returns_most_frequent_request_type
    process_payload(data_2)
    assert_equal "POST", PayloadRequest.most_frequent_request_type
    process_payload(data_1)
    process_payload(data_3)
    assert_equal "GET", PayloadRequest.most_frequent_request_type
  end

  def test_returns_all_request_types
    process_payload(data_1)
    process_payload(data_2)
    process_payload(data_3)
    assert_equal 2, RequestType.all.count
    assert_equal ["GET", "POST"], PayloadRequest.all_request_types
  end

  def test_it_returns_a_descending_list_of_most_requested
    process_payload(data_1)
    process_payload(data_2)
    process_payload(data_3)
    process_payload(data_4)
    process_payload(data_8)
    process_payload(data_9)
    assert_equal 3, Url.count
    assert_equal ["http://jumpstartlab.com/blog", "http://google.com/translate", "http://google.com/maps"], PayloadRequest.most_to_least
  end

  def test_it_can_find_browsers_across_all_requests
    process_payload(data_1)
    process_payload(data_2)
    assert_equal ({"Chrome" => 2}), PayloadRequest.browsers
    assert_equal 1, UAgent.count
  end

  def test_it_can_find_operating_systems_across_all_requests
    process_payload(data_1)
    process_payload(data_2)
    assert_equal ({"OS X 10.8.2" => 2}), PayloadRequest.operating_systems
    process_payload(data_3)
    assert_equal ({"OS X 10.8.2" => 2, "Corel Linux" => 1}), PayloadRequest.operating_systems
    assert_equal 2, UAgent.count
  end

  def test_it_can_find_all_resolutions_across_all_requests
    process_payload(data_1)
    process_payload(data_2)
    assert_equal ({"1920 x 1280" => 2}), PayloadRequest.all_resolutions
    assert_equal 1, Resolution.count
  end

  def test_it_can_find_all_client_paths
    process_payload(data_1)
    process_payload(data_8)
    process_payload(data_9)
    assert_equal ["/translate", "/maps"], PayloadRequest.all_client_paths
    assert_equal 2, Url.all_paths.count
  end
end
