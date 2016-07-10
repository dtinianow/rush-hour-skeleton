ENV["RACK_ENV"] ||= "test"

require 'bundler'
Bundler.require

require File.expand_path("../../config/environment", __FILE__)
require 'minitest/autorun'
require 'minitest/pride'
require 'capybara/dsl'
require 'database_cleaner'
require 'json'

DatabaseCleaner.strategy = :truncation

module TestHelpers

  def setup
    DatabaseCleaner.start
    super
  end

  def teardown
    DatabaseCleaner.clean
    super
  end

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
    "referredBy": "http://google.com",
    "requestType": "GET",
    "userAgent": "Mozilla/5.0 (AOL; Corel Linux) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1309.0 Safari/537.17",
    "resolutionWidth": "1920",
    "resolutionHeight": "1280",
    "ip": "63.29.38.211"
    }'
  end

  def data_4
    '{
    "url": "http://jumpstartlab.com/blog",
    "requestedAt": "2013-02-16 21:38:28 -0700",
    "respondedIn": 66,
    "referredBy": "http://google.com",
    "requestType": "GET",
    "userAgent": "Mozilla/5.0 (Chrome; iOS) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1309.0 Safari/537.17",
    "resolutionWidth": "1920",
    "resolutionHeight": "1280",
    "ip": "63.29.38.211"
    }'
  end

  def data_5
    '{
    "url": "http://jumpstartlab.com/blog",
    "requestedAt": "2013-02-16 21:38:28 -0700",
    "respondedIn": 66,
    "referredBy": "http://facebook.com",
    "requestType": "GET",
    "userAgent": "Mozilla/5.0 (Chrome; iOS) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1309.0 Safari/537.17",
    "resolutionWidth": "1920",
    "resolutionHeight": "1280",
    "ip": "63.29.38.211"
    }'
  end

  def data_6
    '{
    "url": "http://jumpstartlab.com/blog",
    "requestedAt": "2013-02-16 21:38:28 -0700",
    "respondedIn": 66,
    "referredBy": "http://facebook.com",
    "requestType": "GET",
    "userAgent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1309.0 Safari/537.17",
    "resolutionWidth": "1920",
    "resolutionHeight": "1280",
    "ip": "63.29.38.211"
    }'
  end

  def data_7
    '{
    "url": "http://jumpstartlab.com/blog",
    "requestedAt": "2013-02-16 21:38:28 -0700",
    "respondedIn": 66,
    "referredBy": "http://facebook.com",
    "requestType": "GET",
    "userAgent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1309.0 Safari/537.17",
    "resolutionWidth": "1920",
    "resolutionHeight": "1280",
    "ip": "63.29.38.211"
    }'
  end

  def data_8
    '{
    "url": "http://google.com/translate",
    "requestedAt": "2013-02-16 21:38:28 -0700",
    "respondedIn": 37,
    "referredBy": "http://google.com",
    "requestType": "POST",
    "userAgent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1309.0 Safari/537.17",
    "resolutionWidth": "1920",
    "resolutionHeight": "1280",
    "ip": "63.29.38.211"
    }'
  end
  def data_9
    '{
    "url": "http://google.com/maps",
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

end

Capybara.app = RushHour::Server

class FeatureTest < Minitest::Test
  include Capybara::DSL
  include TestHelpers
end
