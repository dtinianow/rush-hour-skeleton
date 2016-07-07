require './test/test_helper'
require 'pry'

class RushHourAppTest < Minitest::Test
  include Rack::Test::Methods, TestHelpers

  def app
    RushHourApp
  end

  def test_create_a_new_client_with_valid_attributes
    post '/sources', { identifier: 'jumpstart' root_url:'' }
    assert_equal 200, last_response.status
    assert_equal "{'identifier':'jumpstart'}", last_response.body
  end

  def test_cannot_create_a_client_with_missing_attributes
    skip
    post '/sources', { identifier: 'jumpstart'}
    assert_equal 400, last_response.status
    post '/sources', { root_url: ''}
  end

  def test_cannot_create_new_client_with_already_existing_identifier
    skip
    post '/sources', { identifier: 'jumpstart', root_url: '' }
    assert_equal 403, last_response.status
  end



end
