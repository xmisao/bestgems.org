require 'minitest/autorun'
require 'database'
require 'batch/update_statistics_total_downloads'
require_relative '../run_migration'
require_relative '../test_helper'

class TestUpdateStatisticsTotalDonwloads < Minitest::Test
  def setup
    TestHelper.delete_all
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
                 :value => 20)
    Value.insert(:id => 3,
                 :type => Value::Type::TOTAL_DOWNLOADS,
                 :gem_id => 3,
                 :date => Date.new(2014, 6, 1),
                 :value => 30)

    StatisticsTotalDownloadsUpdater.execute(Date.new(2014, 6, 1))

    stat = Statistics.where(:type => Statistics::Type::TOTAL_DOWNLOADS,
                            :date => Date.new(2014, 6, 1)).first
    assert_equal 60, stat[:value]
  end
end
