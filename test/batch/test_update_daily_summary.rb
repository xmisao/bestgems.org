require 'minitest/autorun'
require 'database'
require 'batch/update_daily_summary'
require_relative '../run_migration'
require_relative '../test_helper'

class TestUpdateDailySummary < Minitest::Test
  def setup
    TestHelper.delete_all
  end

  def test_execute_when_insert
    Gems.insert(id: 1, name: 'foo')
    Gems.insert(id: 2, name: 'bar')

    Ranking.insert(type: Ranking::Type::TOTAL_RANKING,
                   gem_id: 1,
                   date: Date.new(2017, 11, 1),
                   ranking: 1)
    Ranking.insert(type: Ranking::Type::TOTAL_RANKING,
                   gem_id: 2,
                   date: Date.new(2017, 11, 1),
                   ranking: 2)
    Ranking.insert(type: Ranking::Type::DAILY_RANKING,
                   gem_id: 1,
                   date: Date.new(2017, 11, 1),
                   ranking: 1)

    DailySummaryUpdater.execute(Date.new(2017, 11, 1))

    assert_equal 1, DailySummary.count
    assert_equal Date.new(2017, 11, 1), DailySummary.first[:date]
    assert_equal 2, DailySummary.first[:ranking_total_count]
    assert_equal 1, DailySummary.first[:ranking_daily_count]
  end

  def test_execute_when_update
    Gems.insert(id: 1, name: 'foo')
    Gems.insert(id: 2, name: 'bar')

    Ranking.insert(type: Ranking::Type::TOTAL_RANKING,
                   gem_id: 1,
                   date: Date.new(2017, 11, 1),
                   ranking: 1)
    Ranking.insert(type: Ranking::Type::TOTAL_RANKING,
                   gem_id: 2,
                   date: Date.new(2017, 11, 1),
                   ranking: 2)
    Ranking.insert(type: Ranking::Type::DAILY_RANKING,
                   gem_id: 1,
                   date: Date.new(2017, 11, 1),
                   ranking: 1)

    DailySummary.insert(date: Date.new(2017, 11, 1), ranking_total_count: 10, ranking_daily_count: 20)

    DailySummaryUpdater.execute(Date.new(2017, 11, 1))

    assert_equal 1, DailySummary.count
    assert_equal Date.new(2017, 11, 1), DailySummary.first[:date]
    assert_equal 2, DailySummary.first[:ranking_total_count]
    assert_equal 1, DailySummary.first[:ranking_daily_count]
  end
end
