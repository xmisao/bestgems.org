require 'minitest/autorun'
require 'database'

class TestTrendData < MiniTest::Unit::TestCase
  def test_initialize
    tdp = TrendData.new(Date.new(2017, 9, 25), 1, 2, 3, 4)

    assert_equal Date.new(2017, 9, 25), tdp.date
    assert_equal 1, tdp.total_downloads
    assert_equal 2, tdp.total_rank
    assert_equal 3, tdp.daily_downloads
    assert_equal 4, tdp.daily_rank
  end

  def test_pack_to_msgpack
    tdp = TrendData.new(Date.new(2017, 9, 25), 1, 2, 3, 4)

    packed_tdp = MessagePack.pack(tdp)

    assert_equal [199, 10, 1, 149, 206, 0, 37, 129, 166, 1, 2, 3, 4], packed_tdp.unpack('C*')
  end

  def test_trend_unpack_from_msgpack
    tdp = TrendData.new(Date.new(2017, 9, 25), 1, 2, 3, 4)

    packed_tdp = [199, 10, 1, 149, 206, 0, 37, 129, 166, 1, 2, 3, 4].pack('C*')

    unpacked_tdp = MessagePack.unpack(packed_tdp)

    assert_equal tdp, unpacked_tdp
  end
end
