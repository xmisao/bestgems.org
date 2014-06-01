require 'minitest/unit'
require 'database'
require 'batch/update_statistics_num_of_gems'
require_relative '../run_migration'

class TestUpdateStatisticsNumOfGems < MiniTest::Unit::TestCase
  def setup
    Gems.where.delete
    Value.where.delete
    Statistics.where.delete
  end

  def test_execute
    Gems.insert(:id => 1,
                :name => 'foo')
    Gems.insert(:id => 2,
                :name => 'bar')
    Gems.insert(:id => 3,
                :name => 'baz')
    Value.insert(:id => 1,
                 :type => Value::Type::TOTAL_DOWNLOADS,
                 :gem_id => 1,
                 :date => Date.new(2014, 6, 1),
                 :value => 10)
    Value.insert(:id => 2,
                 :type => Value::Type::TOTAL_DOWNLOADS,
                 :gem_id => 2,
                 :date => Date.new(2014, 6, 1),
                 :value => 10)
    Value.insert(:id => 3,
                 :type => Value::Type::TOTAL_DOWNLOADS,
                 :gem_id => 3,
                 :date => Date.new(2014, 6, 1),
                 :value => 10)

    StatisticsNumOfGemsUpdater.execute(Date.new(2014, 6, 1))

    stat = Statistics.where(:type => Statistics::Type::NUM_OF_GEMS,
                            :date => Date.new(2014, 6, 1)).first
    assert_equal 3, stat[:value]
  end
end
