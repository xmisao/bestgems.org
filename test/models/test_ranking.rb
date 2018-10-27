require "minitest/autorun"
require "database"
require "batch/update_gems_latest_columns"
require_relative "../run_migration"

class TestRanking < Minitest::Test
  def setup
    TestHelper.delete_all
  end

  def test_total
    Gems.insert(:id => 1,
                :name => "foo",
                :version => "1.0",
                :summary => "Awesome gem.")
    Value.insert(:type => Value::Type::TOTAL_DOWNLOADS,
                 :gem_id => 1,
                 :date => Date.new(2014, 6, 1),
                 :value => 42)
    Ranking.insert(:type => Ranking::Type::TOTAL_RANKING,
                   :gem_id => 1,
                   :date => Date.new(2014, 6, 1),
                   :ranking => 20)
    Value.insert(:type => Value::Type::DAILY_DOWNLOADS,
                 :gem_id => 1,
                 :date => Date.new(2014, 6, 1),
                 :value => 23)
    Ranking.insert(:type => Ranking::Type::DAILY_RANKING,
                   :gem_id => 1,
                   :date => Date.new(2014, 6, 1),
                   :ranking => 10)
    GemsLatestColumnsUpdater.execute(Date.new(2014, 6, 1))

    total = Ranking.total(Date.new(2014, 6, 1), 1)
    top = total.first

    assert_equal "foo", top[:name]
    assert_equal "Awesome gem.", top[:summary]
    assert_equal 42, top[:downloads]
    assert_equal 20, top[:ranking]
  end

  def test_total_count_return_summary_data
    DailySummary.insert(:date => Date.new(2017, 11, 1), ranking_total_count: 2)

    assert_equal 2, Ranking.total_count(Date.new(2017, 11, 1))
  end

  def test_total_count_return_ranking_count
    Gems.insert(id: 1,
                name: "foo",
                version: "1.0",
                summary: "Awesome gem.",
                latest_total_ranking: 10,
                latest_update_date: Date.new(2017, 11, 1))
    Gems.insert(id: 2,
                name: "bar",
                version: "1.0",
                summary: "Awesome gem.",
                latest_total_ranking: 20,
                latest_update_date: Date.new(2017, 11, 1))

    assert_equal 2, Ranking.total_count(Date.new(2017, 11, 1))
  end

  def test_daily
    Gems.insert(:id => 1,
                :name => "foo",
                :version => "1.0",
                :summary => "Awesome gem.")
    Value.insert(:type => Value::Type::TOTAL_DOWNLOADS,
                 :gem_id => 1,
                 :date => Date.new(2014, 6, 1),
                 :value => 42)
    Ranking.insert(:type => Ranking::Type::TOTAL_RANKING,
                   :gem_id => 1,
                   :date => Date.new(2014, 6, 1),
                   :ranking => 20)
    Value.insert(:type => Value::Type::DAILY_DOWNLOADS,
                 :gem_id => 1,
                 :date => Date.new(2014, 6, 1),
                 :value => 23)
    Ranking.insert(:type => Ranking::Type::DAILY_RANKING,
                   :gem_id => 1,
                   :date => Date.new(2014, 6, 1),
                   :ranking => 10)
    GemsLatestColumnsUpdater.execute(Date.new(2014, 6, 1))

    daily = Ranking.daily(Date.new(2014, 6, 1), 1)
    top = daily.first

    assert_equal "foo", top[:name]
    assert_equal "Awesome gem.", top[:summary]
    assert_equal 23, top[:downloads]
    assert_equal 10, top[:ranking]
  end

  def test_daily_count_return_summary_data
    DailySummary.insert(:date => Date.new(2017, 11, 1), ranking_daily_count: 2)

    assert_equal 2, Ranking.daily_count(Date.new(2017, 11, 1))
  end

  def test_daily_count_return_ranking_count
    Gems.insert(id: 1,
                name: "foo",
                version: "1.0",
                summary: "Awesome gem.",
                latest_daily_ranking: 10,
                latest_update_date: Date.new(2017, 11, 1))
    Gems.insert(id: 2,
                name: "bar",
                version: "1.0",
                summary: "Awesome gem.",
                latest_daily_ranking: 20,
                latest_update_date: Date.new(2017, 11, 1))

    assert_equal 2, Ranking.daily_count(Date.new(2017, 11, 1))
  end

  def test_featured
    Gems.insert(:id => 1,
                :name => "foo",
                :version => "1.0",
                :summary => "Awesome gem.")
    Value.insert(:type => Value::Type::TOTAL_DOWNLOADS,
                 :gem_id => 1,
                 :date => Date.new(2014, 6, 1),
                 :value => 42)
    Ranking.insert(:type => Ranking::Type::TOTAL_RANKING,
                   :gem_id => 1,
                   :date => Date.new(2014, 6, 1),
                   :ranking => 20)
    Value.insert(:type => Value::Type::DAILY_DOWNLOADS,
                 :gem_id => 1,
                 :date => Date.new(2014, 6, 1),
                 :value => 23)
    Ranking.insert(:type => Ranking::Type::DAILY_RANKING,
                   :gem_id => 1,
                   :date => Date.new(2014, 6, 1),
                   :ranking => 10)
    Value.insert(:type => Value::Type::FEATURED_SCORE,
                 :gem_id => 1,
                 :date => Date.new(2014, 6, 1),
                 :value => 10)
    Ranking.insert(:type => Ranking::Type::FEATURED_RANKING,
                   :gem_id => 1,
                   :date => Date.new(2014, 6, 1),
                   :ranking => 30)
    GemsLatestColumnsUpdater.execute(Date.new(2014, 6, 1))

    featured = Ranking.featured(Date.new(2014, 6, 1), 1)
    top = featured.first

    assert_equal "foo", top[:name]
    assert_equal "Awesome gem.", top[:summary]
    assert_equal 30, top[:ranking]
    assert_equal 10, top[:score]
    assert_equal 20, top[:total_ranking]
    assert_equal 10, top[:daily_ranking]
  end
end
