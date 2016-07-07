require_relative '../test_helper.rb'

class UrlTest < Minitest::Test
  include TestHelpers, DataProcessor

  def data_1
    '{
      "url": "http://google.com/translate",
      "requestedAt": "2013-02-16 21:38:28 -0700",
      "respondedIn": 37,
      "referredBy": "http://google.com",
      "requestType": "GET",
      "userAgent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1309.0 Safari/537.17",
      "resolutionWidth": "1920",
      "resolutionHeight": "1280",
      "ip": "63.29.38.211"
     }'
  end

  def data_2
    '{
    "url": "http://jumpstartlab.com/blog",
    "requestedAt": "2013-02-16 21:38:28 -0700",
    "respondedIn": 50,
    "referredBy": "http://jumpstartlab.com",
    "requestType": "POST",
    "userAgent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1309.0 Safari/537.17",
    "resolutionWidth": "1920",
    "resolutionHeight": "1280",
    "ip": "63.29.38.211"
    }'
  end

  def data_3
    '{
    "url": "http://jumpstartlab.com/blog",
    "requestedAt": "2013-02-16 21:38:28 -0700",
    "respondedIn": 66,
    "referredBy": "http://jumpstartlab.com",
    "requestType": "GET",
    "userAgent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1309.0 Safari/537.17",
    "resolutionWidth": "1920",
    "resolutionHeight": "1280",
    "ip": "63.29.38.211"
    }'

  end

  def test_it_can_hold_a_root_url_and_path
    url = Url.create(root_url: "http://www.google.com", path: "/")
    assert_equal '/', url.path
    assert_equal 'http://www.google.com', url.root_url
    assert url.valid?
  end

  def test_it_returns_all_paths
    Url.create(root_url: "http://www.google.com", path: "/maps")
    Url.create(root_url: "http://www.google.com", path: "/translate")
    Url.create(root_url: "http://www.google.com", path: "/maps")

    assert_equal 3, Url.all.count
    assert_equal ["/maps", "/translate"], Url.all_paths
  end

  def test_it_returns_all_root_urls
    Url.create(root_url: "http://www.facebook.com", path: "/photos")
    Url.create(root_url: "http://www.google.com", path: "/translate")
    Url.create(root_url: "http://www.facebook.com", path: "/about")

    assert_equal 3, Url.all.count
    assert_equal ["http://www.facebook.com", "http://www.google.com"], Url.all_roots
  end

  def test_it_returns_a_descending_list_of_most_requested
    Url.create(root_url: "http://www.facebook.com", path: "/photos")
    Url.create(root_url: "http://www.google.com", path: "/translate")
    Url.create(root_url: "http://www.facebook.com", path: "/about")
    Url.create(root_url: "http://www.google.com", path: "/translate")
    Url.create(root_url: "http://www.facebook.com", path: "/about")
    Url.create(root_url: "http://www.facebook.com", path: "/about")

    assert_equal 6, Url.all.count
    assert_equal ["http://www.facebook.com/about", "http://www.google.com/translate", "http://www.facebook.com/photos"], Url.most_to_least
  end

  def test_finds_the_max_response_time
    process_payload(data_1)
    process_payload(data_2)
    process_payload(data_3)

    assert_equal 3, PayloadRequest.all.count

    assert_equal 2, Url.all.count

    assert_equal "http://jumpstartlab.com/blog", Url.assemble_url(2)

    assert_equal 66, Url.find(2).payload_requests.maximum(:responded_in)
  end

  def test_finds_the_min_response_time
    process_payload(data_1)
    process_payload(data_2)
    process_payload(data_3)

    assert_equal 37, Url.find(1).payload_requests.minimum(:responded_in)
  end

  def test_it_gives_a_list_of_response_times_from_longest_to_shortest
    process_payload(data_1)
    process_payload(data_2)
    process_payload(data_3)

    assert_equal [66, 50], Url.response_times(2)
    assert_equal [37], Url.response_times(1)
  end

  def test_it_finds_average_response_time
    process_payload(data_1)
    process_payload(data_2)
    process_payload(data_3)

    assert_equal 58, Url.find(2).payload_requests.average(:responded_in)
  end

  def test_it_finds_verbs_associated_with_url
    process_payload(data_1)
    process_payload(data_2)
    process_payload(data_3)


   assert_equal ["GET", "POST"], Url.verbs_used(2)
  end
end
