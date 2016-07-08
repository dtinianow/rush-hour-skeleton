require './test/test_helper'

class ClientTest < Minitest::Test
  include TestHelpers

  def test_it_holds_an_identifier_and_root_url
    Client.create(identifier: 'jumpstartlab', root_url: 'http://www.jumpstartlab.com')

    assert_equal 1, Client.count
    assert_equal 'jumpstartlab', Client.find(1).identifier
    assert_equal 'http://www.jumpstartlab.com', Client.find(1).root_url
  end

  def test_it_cannot_be_created_without_an_identifier
    Client.create(root_url: 'http://www.jumpstartlab.com')

    assert_equal 0, Client.count
  end

  def test_it_cannot_be_created_without_a_root_url
    Client.create(identifier: 'jumpstartlab')

    assert_equal 0, Client.count
  end
end
