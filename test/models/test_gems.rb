require 'minitest/unit'
require 'database'
require_relative '../run_migration'

class TestRanking < MiniTest::Unit::TestCase
  def setup
    Gems.where.delete
    Value.where.delete
    Ranking.where.delete
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
end
