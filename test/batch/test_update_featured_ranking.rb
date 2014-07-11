require 'minitest/unit'
require 'database'
require 'batch/update_featured_ranking'
require_relative '../run_migration'

class TestUpdateFeaturedRanking < MiniTest::Unit::TestCase
  def setup
    Value.where.delete
    Ranking.where.delete
    Gems.where.delete
  end

  def test_execute
    Gems.insert(:id => 1,
                :name => 'foo')
    Gems.insert(:id => 2,
                :name => 'bar')
    Gems.insert(:id => 3,
                :name => 'baz')
    Gems.insert(:id => 4,
                :name => 'qux')
    Value.insert(:id => 1,
                 :type => Value::Type::FEATURED_SCORE,
                 :gem_id => 1,
                 :date => Date.new(2014, 6, 1),
                 :value => 10)
    Value.insert(:id => 2,
                 :type => Value::Type::FEATURED_SCORE,
                 :gem_id => 2,
                 :date => Date.new(2014, 6, 1),
                 :value => 20)
    Value.insert(:id => 3,
                 :type => Value::Type::FEATURED_SCORE,
                 :gem_id => 3,
                 :date => Date.new(2014, 6, 1),
                 :value => 20)
    Value.insert(:id => 4,
                 :type => Value::Type::FEATURED_SCORE,
                 :gem_id => 4,
                 :date => Date.new(2014, 6, 1),
                 :value => 30)

    FeaturedRankingUpdater.execute(Date.new(2014, 6, 1))

    ranking = Ranking.where(:gem_id => 1).first
    assert_equal Ranking::Type::FEATURED_RANKING, ranking[:type]
    assert_equal Date.new(2014, 6, 1), ranking[:date]
    assert_equal 4, ranking[:ranking]
    ranking = Ranking.where(:gem_id => 2).first
    assert_equal Ranking::Type::FEATURED_RANKING, ranking[:type]
    assert_equal Date.new(2014, 6, 1), ranking[:date]
    assert_equal 2, ranking[:ranking]
    ranking = Ranking.where(:gem_id => 3).first
    assert_equal Ranking::Type::FEATURED_RANKING, ranking[:type]
    assert_equal Date.new(2014, 6, 1), ranking[:date]
    assert_equal 2, ranking[:ranking]
    ranking = Ranking.where(:gem_id => 4).first
    assert_equal Ranking::Type::FEATURED_RANKING, ranking[:type]
    assert_equal Date.new(2014, 6, 1), ranking[:date]
    assert_equal 1, ranking[:ranking]
  end
end
