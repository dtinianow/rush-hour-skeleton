require_relative '../test_helper.rb'

class UAgentTest < Minitest::Test
  include TestHelpers, DataProcessor

  def test_it_can_hold_info_on_browser_and_operating_system
    user_agent = UAgent.create(browser: "Chrome", operating_system: "Macintosh")
    assert user_agent.valid?
    assert_equal 'Chrome', user_agent.browser
    assert_equal 'Macintosh', user_agent.operating_system
  end

  def test_browser_breakdown_across_all_requests
    date_time = DateTime.new

    UAgent.create(browser: "Chrome", operating_system: "Macintosh")
    PayloadRequest.create(requested_at: date_time, responded_in: 30, url_id: 1, referred_by_id: 2, request_type_id: 3, u_agent_id: 1, resolution_id: 5, ip_id: 6)

    UAgent.create(browser: "Dolphin", operating_system: "Windows")
    PayloadRequest.create(requested_at: date_time, responded_in: 30, url_id: 1, referred_by_id: 2, request_type_id: 3, u_agent_id: 2, resolution_id: 5, ip_id: 6)

    UAgent.create(browser: "Firefox", operating_system: "Linux")
    PayloadRequest.create(requested_at: date_time, responded_in: 30, url_id: 1, referred_by_id: 2, request_type_id: 3, u_agent_id: 3, resolution_id: 5, ip_id: 6)

    UAgent.create(browser: "Chrome", operating_system: "Windows")
    PayloadRequest.create(requested_at: date_time, responded_in: 30, url_id: 1, referred_by_id: 2, request_type_id: 3, u_agent_id: 4, resolution_id: 5, ip_id: 6)
    #let's add another payload request coming in!
    PayloadRequest.create(requested_at: date_time, responded_in: 30, url_id: 1, referred_by_id: 2, request_type_id: 3, u_agent_id: 4, resolution_id: 5, ip_id: 6)

    assert_equal ({"Dolphin"=>1, "Chrome"=>3, "Firefox"=>1}), UAgent.browser_breakdown
  end

  def test_os_breakdown_across_all_requests
    date_time = DateTime.new

    UAgent.create(browser: "Chrome", operating_system: "Macintosh")
    PayloadRequest.create(requested_at: date_time, responded_in: 30, url_id: 1, referred_by_id: 2, request_type_id: 3, u_agent_id: 1, resolution_id: 5, ip_id: 6)

    UAgent.create(browser: "Dolphin", operating_system: "Macintosh")
    PayloadRequest.create(requested_at: date_time, responded_in: 30, url_id: 1, referred_by_id: 2, request_type_id: 3, u_agent_id: 2, resolution_id: 5, ip_id: 6)

    UAgent.create(browser: "Firefox", operating_system: "Linux")
    PayloadRequest.create(requested_at: date_time, responded_in: 30, url_id: 1, referred_by_id: 2, request_type_id: 3, u_agent_id: 3, resolution_id: 5, ip_id: 6)

    UAgent.create(browser: "Chrome", operating_system: "Windows")
    PayloadRequest.create(requested_at: date_time, responded_in: 30, url_id: 1, referred_by_id: 2, request_type_id: 3, u_agent_id: 4, resolution_id: 5, ip_id: 6)

    #let's add another payload request coming in!
    PayloadRequest.create(requested_at: date_time, responded_in: 30, url_id: 1, referred_by_id: 2, request_type_id: 3, u_agent_id: 3, resolution_id: 5, ip_id: 6)

    assert_equal ({"Linux"=>2, "Windows"=>1, "Macintosh"=>2}), UAgent.os_breakdown
  end

  def test_it_can_produce_browser_for_all_and_os_for_all_from_raw
    request = '{
              "url": "http://jumpstartlab.com/blog",
              "requestedAt": "2013-02-16 21:38:28 -0700",
              "respondedIn": 37,
              "referredBy": "http://jumpstartlab.com",
              "requestType": "GET",
              "userAgent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1309.0 Safari/537.17",
              "resolutionWidth": "1920",
              "resolutionHeight": "1280",
              "ip": "63.29.38.211"
            }'
    UAgent.create(browser: "Chrome", operating_system: "Macintosh")
    #this next uagent object will never be invoked, but we make it exist as a row in the UAgent table. Testing that it is using the correct table interactions.
    UAgent.create(browser: "Dolphin", operating_system: "Windows")
    process_payload(request) #make one payload request
    process_payload(request) #now make another payload request
    assert_equal ({"OS X 10.8.2"=>2}), UAgent.os_breakdown
    assert_equal ({"Chrome"=>2}), UAgent.browser_breakdown
  end

end
