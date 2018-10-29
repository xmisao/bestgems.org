require "minitest/autorun"
require "database"
require "batch/update_daily_summary"
require_relative "../run_migration"
require_relative "../test_helper"

class TestUpdateDailySummary < Minitest::Test
  def setup
    TestHelper.delete_all
  end

  def test_execute_when_insert
    Gems.insert(id: 1, name: "foo", latest_total_ranking: 1, latest_daily_ranking: 1, latest_update_date: Date.new(2017, 11, 1))
    Gems.insert(id: 2, name: "bar", latest_total_ranking: 2, latest_daily_ranking: nil, latest_update_date: Date.new(2017, 11, 1))

    DailySummaryUpdater.execute(Date.new(2017, 11, 1))

    assert_equal 1, DailySummary.count
    assert_equal Date.new(2017, 11, 1), DailySummary.first[:date]
    assert_equal 2, DailySummary.first[:ranking_total_count]
    assert_equal 1, DailySummary.first[:ranking_daily_count]
  end

  def test_execute_when_update
    Gems.insert(id: 1, name: "foo", latest_total_ranking: 1, latest_daily_ranking: 1, latest_update_date: Date.new(2017, 11, 1))
    Gems.insert(id: 2, name: "bar", latest_total_ranking: 2, latest_daily_ranking: nil, latest_update_date: Date.new(2017, 11, 1))

    DailySummary.insert(date: Date.new(2017, 11, 1), ranking_total_count: 10, ranking_daily_count: 20)

    DailySummaryUpdater.execute(Date.new(2017, 11, 1))

    assert_equal 1, DailySummary.count
    assert_equal Date.new(2017, 11, 1), DailySummary.first[:date]
    assert_equal 2, DailySummary.first[:ranking_total_count]
    assert_equal 1, DailySummary.first[:ranking_daily_count]
  end
end
