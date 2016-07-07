require_relative '../test_helper.rb'

class UrlTest < Minitest::Test
  include TestHelpers, DataProcessor

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
      data1 = '{
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

      data2 = '{
        "url": "http://jumpstartlab.com/blog",
        "requestedAt": "2013-02-16 21:38:28 -0700",
        "respondedIn": 50,
        "referredBy": "http://jumpstartlab.com",
        "requestType": "GET",
        "userAgent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1309.0 Safari/537.17",
        "resolutionWidth": "1920",
        "resolutionHeight": "1280",
        "ip": "63.29.38.211"
       }'

      data3 = '{
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

      process_payload(data1)
      process_payload(data2)
      process_payload(data3)

      assert_equal 3, PayloadRequest.all.count

      assert_equal 3, Url.all.count

      assert_equal "http://jumpstartlab.com/blog", Url.find(1).assemble_url

      assert_equal 66, Url.find(1).find_max_response_time

  end
end
