require 'minitest/autorun'
require 'database'
require_relative '../run_migration'

class TestRanking < MiniTest::Unit::TestCase
  def setup
    TestHelper.delete_all
  end

  def test_search
    Gems.insert(:id => 1,
                :name => 'foo',
                :version => '1.0',
                :summary => 'FOO gem')
    Gems.insert(:id => 2,
                :name => 'bar',
                :version => '1.0',
                :summary => 'BAR gem')
    Gems.insert(:id => 3,
                :name => 'foobar',
                :version => '1.0',
                :summary => 'BAZ gem')
    Ranking.insert(:id => 1,
                   :type => Ranking::Type::TOTAL_RANKING,
                   :gem_id => 1,
                   :date => Date.new(2014, 6, 1),
                   :ranking => 10)
    Ranking.insert(:id => 2,
                   :type => Ranking::Type::TOTAL_RANKING,
                   :gem_id => 2,
                   :date => Date.new(2014, 6, 1),
                   :ranking => 20)
    Ranking.insert(:id => 3,
                   :type => Ranking::Type::TOTAL_RANKING,
                   :gem_id => 3,
                   :date => Date.new(2014, 6, 1),
                   :ranking => 30)
    Value.insert(:id => 1,
                 :type => Value::Type::TOTAL_DOWNLOADS,
                 :gem_id => 1,
                 :date => Date.new(2014, 6, 1),
                 :value => 300)
    Value.insert(:id => 2,
                 :type => Value::Type::TOTAL_DOWNLOADS,
                 :gem_id => 2,
                 :date => Date.new(2014, 6, 1),
                 :value => 200)
    Value.insert(:id => 3,
                 :type => Value::Type::TOTAL_DOWNLOADS,
                 :gem_id => 3,
                 :date => Date.new(2014, 6, 1),
                 :value => 100)
    result = Gems.search(Date.new(2014, 6, 1), "foo bar baz")
    gem = result.first

    assert_equal 1, result.count
    assert_equal 'foobar', gem[:name]
    assert_equal 'BAZ gem', gem[:summary]
    assert_equal 30, gem[:ranking]
    assert_equal 100, gem[:downloads]
  end

  def test_total_downloads_trends
    Gems.insert(:id => 1,
                :name => 'foo',
                :version => '1.0',
                :summary => 'FOO gem')
    Value.insert(:id => 1,
                 :type => Value::Type::TOTAL_DOWNLOADS,
                 :gem_id => 1,
                 :date => Date.new(2014, 6, 1),
                 :value => 10)
    Value.insert(:id => 2,
                 :type => Value::Type::TOTAL_DOWNLOADS,
                 :gem_id => 1,
                 :date => Date.new(2014, 6, 2),
                 :value => 20)

    trends = Gems[1].total_downloads_trends.all

    assert_equal 2, trends.length
    assert_equal Date.new(2014, 6, 1), trends[0][:date]
    assert_equal 10, trends[0][:downloads]
    assert_equal Date.new(2014, 6, 2), trends[1][:date]
    assert_equal 20, trends[1][:downloads]
  end

  def test_daily_downloads_trends
    Gems.insert(:id => 1,
                :name => 'foo',
                :version => '1.0',
                :summary => 'FOO gem')
    Value.insert(:id => 1,
                 :type => Value::Type::DAILY_DOWNLOADS,
                 :gem_id => 1,
                 :date => Date.new(2014, 6, 1),
                 :value => 10)
    Value.insert(:id => 2,
                 :type => Value::Type::DAILY_DOWNLOADS,
                 :gem_id => 1,
                 :date => Date.new(2014, 6, 2),
                 :value => 20)

    trends = Gems[1].daily_downloads_trends.all

    assert_equal 2, trends.length
    assert_equal Date.new(2014, 6, 1), trends[0][:date]
    assert_equal 10, trends[0][:downloads]
    assert_equal Date.new(2014, 6, 2), trends[1][:date]
    assert_equal 20, trends[1][:downloads]
  end

  def test_downloads_trends
    Gems.insert(:id => 1,
                :name => 'foo',
                :version => '1.0',
                :summary => 'FOO gem')
    Value.insert(:id => 1,
                 :type => Value::Type::TOTAL_DOWNLOADS,
                 :gem_id => 1,
                 :date => Date.new(2014, 6, 1),
                 :value => 100)
    Value.insert(:id => 2,
                 :type => Value::Type::TOTAL_DOWNLOADS,
                 :gem_id => 1,
                 :date => Date.new(2014, 6, 2),
                 :value => 110)
    Value.insert(:id => 3,
                 :type => Value::Type::DAILY_DOWNLOADS,
                 :gem_id => 1,
                 :date => Date.new(2014, 6, 2),
                 :value => 10)

    trends = Gems[1].downloads_trends.all

    assert_equal 2, trends.length
    assert_equal Date.new(2014, 6, 1), trends[0][:date]
    assert_equal 100, trends[0][:total_downloads]
    assert_equal Date.new(2014, 6, 2), trends[1][:date]
    assert_equal 110, trends[1][:total_downloads]
    assert_equal 10, trends[1][:daily_downloads]
  end

  def test_total_ranking_trends
    Gems.insert(:id => 1,
                :name => 'foo',
                :version => '1.0',
                :summary => 'FOO gem')
    Ranking.insert(:id => 1,
                   :type => Ranking::Type::TOTAL_RANKING,
                   :gem_id => 1,
                   :date => Date.new(2014, 6, 1),
                   :ranking => 1)
    Ranking.insert(:id => 2,
                   :type => Ranking::Type::TOTAL_RANKING,
                   :gem_id => 1,
                   :date => Date.new(2014, 6, 2),
                   :ranking => 2)

    trends = Gems[1].total_ranking_trends.all

    assert_equal 2, trends.length
    assert_equal Date.new(2014, 6, 1), trends[0][:date]
    assert_equal 1, trends[0][:ranking]
    assert_equal Date.new(2014, 6, 2), trends[1][:date]
    assert_equal 2, trends[1][:ranking]
  end

  def test_daily_ranking_trends
    Gems.insert(:id => 1,
                :name => 'foo',
                :version => '1.0',
                :summary => 'FOO gem')
    Ranking.insert(:id => 1,
                   :type => Ranking::Type::DAILY_RANKING,
                   :gem_id => 1,
                   :date => Date.new(2014, 6, 1),
                   :ranking => 1)
    Ranking.insert(:id => 2,
                   :type => Ranking::Type::DAILY_RANKING,
                   :gem_id => 1,
                   :date => Date.new(2014, 6, 2),
                   :ranking => 2)

    trends = Gems[1].daily_ranking_trends.all

    assert_equal 2, trends.length
    assert_equal Date.new(2014, 6, 1), trends[0][:date]
    assert_equal 1, trends[0][:ranking]
    assert_equal Date.new(2014, 6, 2), trends[1][:date]
    assert_equal 2, trends[1][:ranking]
  end

  def test_ranking_trends
    Gems.insert(:id => 1,
                :name => 'foo',
                :version => '1.0',
                :summary => 'FOO gem')
    Ranking.insert(:id => 1,
                   :type => Ranking::Type::TOTAL_RANKING,
                   :gem_id => 1,
                   :date => Date.new(2014, 6, 1),
                   :ranking => 1)
    Ranking.insert(:id => 2,
                   :type => Ranking::Type::TOTAL_RANKING,
                   :gem_id => 1,
                   :date => Date.new(2014, 6, 2),
                   :ranking => 2)
    Ranking.insert(:id => 3,
                   :type => Ranking::Type::DAILY_RANKING,
                   :gem_id => 1,
                   :date => Date.new(2014, 6, 2),
                   :ranking => 3)

    trends = Gems[1].ranking_trends.all

    assert_equal 2, trends.length
    assert_equal Date.new(2014, 6, 1), trends[0][:date]
    assert_equal 1, trends[0][:total_ranking]
    assert_equal Date.new(2014, 6, 2), trends[1][:date]
    assert_equal 2, trends[1][:total_ranking]
    assert_equal 3, trends[1][:daily_ranking]
  end

  def test_info
    Gems.insert(:id => 1,
                :name => 'foo',
                :version => '1.0',
                :summary => 'FOO gem')
    Value.insert(:id => 1,
                 :type => Value::Type::TOTAL_DOWNLOADS,
                 :gem_id => 1,
                 :date => Date.new(2014, 6, 1),
                 :value => 10)
    Value.insert(:id => 2,
                 :type => Value::Type::DAILY_DOWNLOADS,
                 :gem_id => 1,
                 :date => Date.new(2014, 6, 1),
                 :value => 20)
    Ranking.insert(:id => 1,
                   :type => Ranking::Type::TOTAL_RANKING,
                   :gem_id => 1,
                   :date => Date.new(2014, 6, 1),
                   :ranking => 30)
    Ranking.insert(:id => 2,
                   :type => Ranking::Type::DAILY_RANKING,
                   :gem_id => 1,
                   :date => Date.new(2014, 6, 1),
                   :ranking => 40)

    info = Gems[1].info(Date.new(2014, 6, 1))

    assert_equal "foo", info[:name]
    assert_equal "1.0", info[:version]
    assert_equal "FOO gem", info[:summary]
    assert_equal 10, info[:total_downloads]
    assert_equal 20, info[:daily_downloads]
    assert_equal 30, info[:total_ranking]
    assert_equal 40, info[:daily_ranking]
  end

  def test_info_total_only
    Gems.insert(:id => 1,
                :name => 'foo',
                :version => '1.0',
                :summary => 'FOO gem')
    Value.insert(:id => 1,
                 :type => Value::Type::TOTAL_DOWNLOADS,
                 :gem_id => 1,
                 :date => Date.new(2014, 6, 1),
                 :value => 10)
    Ranking.insert(:id => 1,
                   :type => Ranking::Type::TOTAL_RANKING,
                   :gem_id => 1,
                   :date => Date.new(2014, 6, 1),
                   :ranking => 30)

    info = Gems[1].info(Date.new(2014, 6, 1))

    assert_equal "foo", info[:name]
    assert_equal "1.0", info[:version]
    assert_equal "FOO gem", info[:summary]
    assert_equal 10, info[:total_downloads]
    assert_equal nil, info[:daily_downloads]
    assert_equal 30, info[:total_ranking]
    assert_equal nil, info[:daily_ranking]
  end

  def test_trend_by_rdb
    Gems.insert(:id => 1,
                :name => 'foo',
                :version => '1.0',
                :summary => 'FOO gem')
    Value.insert(:id => 1,
                 :type => Value::Type::TOTAL_DOWNLOADS,
                 :gem_id => 1,
                 :date => Date.new(2017, 10, 1),
                 :value => 10)
    Value.insert(:id => 2,
                 :type => Value::Type::DAILY_DOWNLOADS,
                 :gem_id => 1,
                 :date => Date.new(2017, 10, 1),
                 :value => 20)
    Ranking.insert(:id => 1,
                   :type => Ranking::Type::TOTAL_RANKING,
                   :gem_id => 1,
                 :date => Date.new(2017, 10, 1),
                   :ranking => 30)
    Ranking.insert(:id => 2,
                   :type => Ranking::Type::DAILY_RANKING,
                   :gem_id => 1,
                   :date => Date.new(2017, 10, 1),
                   :ranking => 40)

    td = Gems[1].get_trend_data_from_rdb(Date.new(2017, 10, 1))

    assert_equal TrendData.new(Date.new(2017, 10, 1), 10, 30, 20, 40), td
  end

  def test_get_trend_data_from_rdb
    Gems.insert(:id => 1,
                :name => 'foo',
                :version => '1.0',
                :summary => 'FOO gem')
    Ranking.insert(:type => Ranking::Type::TOTAL_RANKING,
                   :gem_id => 1,
                   :date => Date.new(2017, 10, 1),
                   :ranking => 10)
    Ranking.insert(:type => Ranking::Type::DAILY_RANKING,
                   :gem_id => 1,
                   :date => Date.new(2017, 10, 1),
                   :ranking => 20)
    Value.insert(:type => Value::Type::TOTAL_DOWNLOADS,
                 :gem_id => 1,
                 :date => Date.new(2017, 10, 1),
                 :value => 100)
    Value.insert(:type => Value::Type::DAILY_DOWNLOADS,
                 :gem_id => 1,
                 :date => Date.new(2017, 10, 1),
                 :value => 200)

    gem = Gems[1]

    td = gem.get_trend_data_from_rdb(Date.new(2017, 10, 1))

    assert_equal TrendData.new(Date.new(2017, 10, 1), 100, 10, 200, 20), td
  end

  def test_get_trend_data_from_rdb_when_no_data
    Gems.insert(:id => 1,
                :name => 'foo',
                :version => '1.0',
                :summary => 'FOO gem')

    gem = Gems[1]

    td = gem.get_trend_data_from_rdb(Date.new(2017, 10, 1))

    assert_equal nil, td
  end

  def test_put_trend_data
    Gems.insert(:id => 1,
                :name => 'foo',
                :version => '1.0',
                :summary => 'FOO gem')

    td = TrendData.new(Date.new(2017, 10, 1), 1, 2, 3, 4)
    Gems[1].put_trend_data(td)

    assert_equal [td], Trend.get_a('1.201710')
  end

  def test_get_trend_data
    Gems.insert(:id => 1,
                :name => 'foo',
                :version => '1.0',
                :summary => 'FOO gem')

    td = TrendData.new(Date.new(2017, 10, 1), 1, 2, 3, 4)
    Trend.put(1, td)

    assert_equal [td], Gems[1].get_trend_data
  end
end
