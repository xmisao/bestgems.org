require 'minitest/autorun'
require 'database'
require_relative '../run_migration'

class TestRanking < Minitest::Test
  def setup
    TestHelper.delete_all
  end

  def test_total
    Gems.insert(:id => 1,
                :name => 'foo',
                :version => '1.0',
                :summary => 'Awesome gem.')
    Value.insert(:id => 1,
                 :type => Value::Type::TOTAL_DOWNLOADS,
                 :gem_id => 1,
                 :date => Date.new(2014, 6, 1),
                 :value => 42)
    Ranking.insert(:id => 1,
                   :type => Ranking::Type::TOTAL_RANKING,
                   :gem_id => 1,
                   :date => Date.new(2014, 6, 1),
                   :ranking => 20)

    total = Ranking.total(Date.new(2014, 6, 1), 1)
    top = total.first

    assert_equal 'foo', top[:name]
    assert_equal 'Awesome gem.', top[:summary]
    assert_equal 42, top[:downloads]
    assert_equal 20, top[:ranking]
  end

  def test_daily
    Gems.insert(:id => 1,
                :name => 'foo',
                :version => '1.0',
                :summary => 'Awesome gem.')
    Value.insert(:id => 1,
                 :type => Value::Type::DAILY_DOWNLOADS,
                 :gem_id => 1,
                 :date => Date.new(2014, 6, 1),
                 :value => 42)
    Ranking.insert(:id => 1,
                   :type => Ranking::Type::DAILY_RANKING,
                   :gem_id => 1,
                   :date => Date.new(2014, 6, 1),
                   :ranking => 10)

    daily = Ranking.daily(Date.new(2014, 6, 1), 1)
    top = daily.first

    assert_equal 'foo', top[:name]
    assert_equal 'Awesome gem.', top[:summary]
    assert_equal 42, top[:downloads]
    assert_equal 10, top[:ranking]
  end

  def test_featured
    Gems.insert(:id => 1,
                :name => 'foo',
                :version => '1.0',
                :summary => 'Awesome gem.')
    Value.insert(:id => 1,
                 :type => Value::Type::FEATURED_SCORE,
                 :gem_id => 1,
                 :date => Date.new(2014, 6, 1),
                 :value => 10)
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
                   :type => Ranking::Type::FEATURED_RANKING,
                   :gem_id => 1,
                   :date => Date.new(2014, 6, 1),
                   :ranking => 30)

    featured = Ranking.featured(Date.new(2014, 6, 1), 1)
    top = featured.first

    assert_equal 'foo', top[:name]
    assert_equal 'Awesome gem.', top[:summary]
    assert_equal 30, top[:ranking]
    assert_equal 10, top[:score]
    assert_equal 20, top[:total_ranking]
    assert_equal 10, top[:daily_ranking]
  end
end
