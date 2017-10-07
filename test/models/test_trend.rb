require 'minitest/autorun'
require 'database'

class TestTrend < MiniTest::Unit::TestCase
  def setup
    TestHelper.delete_all
  end

  def test_put_a_get_a
    test_key = 'test_key'
    test_td_list = [TrendData.new(Date.new(2017, 9, 25), 1, 2, 3, 4)]

    Trend.put_a(test_key, test_td_list)

    td_list = Trend.get_a(test_key)

    assert_equal test_td_list, td_list
  end

  def test_all
    test_key = 'test_key'
    test_td_list = [TrendData.new(Date.new(2017, 9, 25), 1, 2, 3, 4)]

    Trend.put_a(test_key, test_td_list)

    n = 0
    Trend.all{|key, td_list|
      assert_equal test_key, key
      assert_equal test_td_list, td_list
      n += 1
    }
    assert_equal 1, n
  end

  def test_delete_a
    test_key = 'test_key'
    test_td_list = [TrendData.new(Date.new(2017, 9, 25), 1, 2, 3, 4)]

    Trend.put_a(test_key, test_td_list)
    Trend.delete_a(test_key)
    td_list = Trend.get_a(test_key)

    assert_equal nil, td_list
  end

  def test_put_one_value
    gem_id = 42
    td = TrendData.new(Date.new(2017, 9, 1), 1, 2, 3, 4)

    Trend.put(gem_id, td)

    assert_equal [td], Trend.get_a(td.key(gem_id))
  end

  def test_put_two_values
    gem_id = 42
    td1 = TrendData.new(Date.new(2017, 9, 1), 1, 2, 3, 4)
    td2 = TrendData.new(Date.new(2017, 10, 1), 1, 2, 3, 4)

    Trend.put(gem_id, td1, td2)

    assert_equal [td1], Trend.get_a(td1.key(gem_id))
    assert_equal [td2], Trend.get_a(td2.key(gem_id))
  end

  def test_put_values_complex_case
    gem_id = 42

    td1_1 = TrendData.new(Date.new(2017, 9, 1), 1, 2, 3, 4) # Exist and updated by new value (1st key)
    td1_2 = TrendData.new(Date.new(2017, 9, 1), 2, 3, 4, 5) # New value for exists value (1st key)
    td2 = TrendData.new(Date.new(2017, 9, 2), 3, 4, 5, 6) # Exist and updated by same value
    td3 = TrendData.new(Date.new(2017, 9, 3), 4, 5, 6, 7) # Exist and not updated
    td4 = TrendData.new(Date.new(2017, 9, 4), 5, 6, 7, 8) # New value (1st key)
    td5_1 = TrendData.new(Date.new(2017, 10, 1), 6, 7, 8, 9) # Exist and updated by new value (2nd key)
    td5_2 = TrendData.new(Date.new(2017, 10, 1), 7, 8, 9, 10) # New value for exists value (2nd key)
    td6 = TrendData.new(Date.new(2017, 11, 1), 8, 9, 10, 11) # New value (3rd key)

    # Create
    Trend.put(gem_id, td1_1, td2, td3, td5_1)

    assert_equal [td1_1, td2, td3], Trend.get_a(td1_1.key(gem_id))
    assert_equal [td5_1], Trend.get_a(td5_1.key(gem_id))

    assert_equal [td1_1, td2, td3, td5_1], Trend.get(gem_id)

    # Update
    Trend.put(gem_id, td1_2, td2, td4, td5_2, td6)

    assert_equal [td1_2, td2, td3, td4], Trend.get_a(td1_1.key(gem_id))
    assert_equal [td5_2], Trend.get_a(td5_2.key(gem_id))
    assert_equal [td6], Trend.get_a(td6.key(gem_id))

    assert_equal [td1_2, td2, td3, td4, td5_2, td6], Trend.get(gem_id)
  end

  def test_get
    gem_id = 42
    td1 = TrendData.new(Date.new(2017, 9, 1), 1, 2, 3, 4)
    td2 = TrendData.new(Date.new(2017, 10, 1), 1, 2, 3, 4)

    Trend.put(gem_id, td1, td2)

    assert_equal [td1, td2], Trend.get(gem_id)
  end

  def test_update
    test_key = 'test_key'
    td1_1 = TrendData.new(Date.new(2017, 9, 1), 1, 2, 3, 4)
    td1_2 = TrendData.new(Date.new(2017, 9, 1), 2, 3, 4, 5)
    td2 = TrendData.new(Date.new(2017, 9, 2), 3, 4, 5, 6)

    # Create
    Trend.update(test_key, [td1_1])

    assert_equal [td1_1], Trend.get_a(test_key)

    # Update
    Trend.update(test_key, [td1_2, td2])

    assert_equal [td1_2, td2], Trend.get_a(test_key)
  end

  def test_merge_td_list
    td1_1 = TrendData.new(Date.new(2017, 9, 1), 1, 2, 3, 4) # Exist and updated by new value
    td1_2 = TrendData.new(Date.new(2017, 9, 1), 2, 3, 4, 5) # New value for exists value
    td2 = TrendData.new(Date.new(2017, 9, 2), 3, 4, 5, 6) # Exist and updated by same value
    td3 = TrendData.new(Date.new(2017, 9, 3), 4, 5, 6, 7) # Exist and not updated
    td4 = TrendData.new(Date.new(2017, 9, 4), 5, 6, 7, 8) # New value

    exist_td_list = [td1_1, td2, td3]
    new_td_list = [td1_2, td2, td4]

    merged_td_list = Trend.merge_td_list(exist_td_list, new_td_list)

    assert_equal [td1_2, td2, td3, td4], merged_td_list
  end

  def test_empty_return_true
    assert_equal true, Trend.empty?
  end

  def test_empty_return_false
    Trend.put_a('test_key', TrendData.new(Date.new(2017, 10, 1), 1, 2, 3, 4))

    assert_equal false, Trend.empty?
  end
end
