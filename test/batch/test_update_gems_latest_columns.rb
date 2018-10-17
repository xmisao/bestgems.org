require "minitest/autorun"
require "database"
require "batch/update_gems_latest_columns"
require_relative "../run_migration"

class TestUpdateGemsLatestColumns < Minitest::Test
  def setup
    TestHelper.delete_all
  end

  def test_execute
    Gems.insert(:id => 1,
                :name => "foo",
                :version => "1.0",
                :summary => "FOO gem")
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

    GemsLatestColumnsUpdater.execute(Date.new(2017, 10, 1))

    updated = Gems.where(id: 1).first

    assert_equal 10, updated[:latest_total_ranking]
    assert_equal 20, updated[:latest_daily_ranking]
    assert_equal 100, updated[:latest_total_downloads]
    assert_equal 200, updated[:latest_daily_downloads]
    assert_equal Date.new(2017, 10, 1), updated[:latest_update_date]
  end

  def test_execute_when_no_data
    Gems.insert(:id => 1,
                :name => "foo",
                :version => "1.0",
                :summary => "FOO gem")

    before = Gems.where(id: 1).first

    GemsLatestColumnsUpdater.execute(Date.new(2017, 10, 1))

    after = Gems.where(id: 1).first

    assert_equal before, after
  end
end
