require 'minitest/unit'
require 'database'
require 'batch/update_featured_score'
require_relative '../run_migration'

class TestUpdateFeaturedScore < MiniTest::Unit::TestCase
  def setup
    Gems.where.delete
    Value.where.delete
    Ranking.where.delete
  end

  def test_update_featured_score
    Gems.insert(:id => 1,
                :name => 'foo')
    Ranking.insert(:id => 1,
                   :type => Ranking::Type::TOTAL_RANKING,
                   :gem_id => 1,
                   :date => Date.new(2014, 6, 1),
                   :ranking => 20)
    Ranking.insert(:id => 2,
                   :type => Ranking::Type::DAILY_RANKING,
                   :gem_id => 1,
                   :date => Date.new(2014, 6, 1),
                   :ranking => 10)

    daily_ranking = Ranking[2]
    score = FeaturedScoreUpdater.update_featured_score(daily_ranking)

    assert_equal Value::Type::FEATURED_SCORE, score[:type]
    assert_equal 1, score[:gem_id]
    assert_equal Date.new(2014, 6, 1), score[:date]
    assert_equal 10, score[:value]
  end

  def test_execute
    Gems.insert(:id => 1,
                :name => 'foo')
    Gems.insert(:id => 2,
                :name => 'bar')
    Ranking.insert(:id => 1,
                   :type => Ranking::Type::TOTAL_RANKING,
                   :gem_id => 1,
                   :date => Date.new(2014, 6, 1),
                   :ranking => 20)
    Ranking.insert(:id => 2,
                   :type => Ranking::Type::DAILY_RANKING,
                   :gem_id => 1,
                   :date => Date.new(2014, 6, 1),
                   :ranking => 10)
    Ranking.insert(:id => 3,
                   :type => Ranking::Type::TOTAL_RANKING,
                   :gem_id => 2,
                   :date => Date.new(2014, 6, 1),
                   :ranking => 40)
    Ranking.insert(:id => 4,
                   :type => Ranking::Type::DAILY_RANKING,
                   :gem_id => 2,
                   :date => Date.new(2014, 6, 1),
                   :ranking => 30)

    FeaturedScoreUpdater.execute(Date.new(2014, 6, 1))

    assert_equal 2, Value.count
  end
end
