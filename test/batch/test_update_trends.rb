require 'minitest/autorun'
require 'database'
require 'batch/update_trends'
require_relative '../run_migration'

class TestUpdateTrend < Minitest::Test
  def setup
    TestHelper.delete_all
  end

  def test_execute
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

    TrendUpdater.execute(Date.new(2017, 10, 1))

    td_list = Gems[1].get_trend_data

    assert_equal [TrendData.new(Date.new(2017, 10, 1), 100, 10, 200, 20)], td_list
  end

  def test_execute_when_no_data
    Gems.insert(:id => 1,
                :name => 'foo',
                :version => '1.0',
                :summary => 'FOO gem')

    TrendUpdater.execute(Date.new(2017, 10, 1))

    td_list = Gems[1].get_trend_data

    assert_equal [], td_list
  end
end
