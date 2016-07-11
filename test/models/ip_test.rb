require_relative '../test_helper.rb'

class IpTest < Minitest::Test
  include TestHelpers

  def test_it_holds_an_address
    ip = Ip.create(address: "1.2.3.4")
    assert_equal "1.2.3.4", ip.address
  end

  def test_it_requires_a_unique_address
    ip = Ip.create(address: "1.2.3.4")
    assert ip.valid?
    assert_equal 1, Ip.count
    ip_2 = Ip.create(address: "1.2.3.4")
    refute ip_2.valid?
    assert_equal 1, Ip.count
  end
end
