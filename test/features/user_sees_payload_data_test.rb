require './test/test_helper'

class UserSeesPayloadDataTest < FeatureTest
  include TestHelpers, DataProcessor

  def populate_client_payload
    client = Client.create(identifier: 'jumpstartlab', root_url: 'http://jumpstartlab.com')
    payload_1 = process_payload(data_2)
    payload_2 = process_payload(data_3)
    PayloadRequest.find(payload_1.id).update_attribute(:client_id, client.id)
    PayloadRequest.find(payload_2.id).update_attribute(:client_id, client.id)
  end

  def test_user_can_see_data_across_all_requests
    populate_client_payload
    visit '/sources/jumpstartlab'
    assert page.find('h1').has_content?("Data for 'jumpstartlab'")
    within ('.top-row') do
      assert page.find('.col-md-3:first').has_content?("58.0 ms")
      assert page.find('.col-md-3:nth-child(2)').has_content?("66.0 ms")
      assert page.find('.col-md-3:nth-child(3)').has_content?("50.0 ms")
      assert page.find('.col-md-3:last').has_content?("POST")
    end
    within ('.second-row') do
      assert page.find('.col-md-6:first').has_content?("POST\nGET")
      assert page.find('.col-md-6:last').has_content?("http://jumpstartlab.com/blog")
    end
    within ('.third-row') do
      assert page.find('.col-md-6:first').has_content?("Chrome (1 requests)")
      assert page.find('.col-md-6:last').has_content?("OS X 10.8.2 (1 requests)\nCorel Linux (1 requests)")
    end
    within ('.last-row') do
      assert page.find('.col-md-6:first').has_content?("1920 x 1280 (2 requests)")
    end
    within ('.last-row') do
      assert page.find('.col-md-6:last').has_content?("/blog")
    end
  end

  def test_user_can_see_data_across_individual_paths
    populate_client_payload
    visit '/sources/jumpstartlab'
    page.click_link('/blog')
    assert '/sources/jumpstartlab/urls/blog', current_path
    page.find('h1').has_content?("Data for 'http://jumpstartlab.com/blog'")
    within ('.top-row') do
      assert page.find('.col-md-3:nth-child(2)').has_content?("66 ms")
      assert page.find('.col-md-3:nth-child(3)').has_content?("50 ms")
      assert page.find('.col-md-3:last').has_content?("58.0 ms")
    end
    within ('.second-row') do
      assert page.find('.col-md-6:first').has_content?("66\n50")
      assert page.find('.col-md-6:last').has_content?("GET\nPOST")
    end
    within ('.last-row') do
      assert page.find('.col-md-6:first').has_content?("http://google.com/\nhttp://jumpstartlab.com/")
      assert page.find('.col-md-6:last').has_content?("Chrome; Corel Linux\nChrome; OS X 10.8.2")
    end
  end

  def test_user_can_return_to_all_request_data_from_individual_path_data
    populate_client_payload
    visit '/sources/jumpstartlab/urls/blog'
    page.click_link("Back to all jumpstartlab data")
    assert '/sources/jumpstartlab', current_path
  end

end
