require_relative '../test_helper.rb'

class ResolutionTest < Minitest::Test
  include TestHelpers, DataProcessor

  def raw_data
    '{
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
  end

  def test_it_can_hold_width_and_height
    resolution = Resolution.create(width: 1280, height: 800)
    assert_equal 1280, resolution.width
    assert_equal 800, resolution.height
    assert resolution.valid?
  end

  def test_it_can_display_all_screen_resolutions
    process_payload(raw_data)
    process_payload(raw_data)
    expected = {2457600 => 2}
    assert_equal expected, Resolution.resolutions
  end
end
