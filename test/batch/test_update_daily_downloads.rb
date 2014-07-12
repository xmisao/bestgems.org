require 'minitest/unit'
require 'database'
require 'batch/update_daily_downloads'
require_relative '../run_migration'

class TestUpdateTotalDownloads < MiniTest::Unit::TestCase
  def setup
    ScrapedData.where.delete
    Gems.where.delete
    Value.where.delete
  end

  def test_generate_daily_downloads
    Gems.insert(:id => 1,
                :name => 'foo')
    Value.insert(:id => 1,
                 :type => Value::Type::TOTAL_DOWNLOADS,
                 :gem_id => 1,
                 :date => Date.new(2014, 6, 1),
                 :value => 20)
    Value.insert(:id => 2,
                 :type => Value::Type::TOTAL_DOWNLOADS,
                 :gem_id => 1,
                 :date => Date.new(2014, 6, 2),
                 :value => 30)

    daily = DailyDownloadsUpdater.generate_daily_downloads(Date.new(2014, 6, 2))[0]

    assert_equal Value::Type::DAILY_DOWNLOADS, daily[:type]
    assert_equal 1, daily[:gem_id]
    assert_equal Date.new(2014, 6, 2), daily[:date]
    assert_equal 10, daily[:value]
  end

  def test_execute
    Gems.insert(:id => 1,
                :name => 'foo')
    Gems.insert(:id => 2,
                :name => 'bar')
    Value.insert(:id => 1,
                 :type => Value::Type::TOTAL_DOWNLOADS,
                 :gem_id => 1,
                 :date => Date.new(2014, 6, 1),
                 :value => 20)
    Value.insert(:id => 2,
                 :type => Value::Type::TOTAL_DOWNLOADS,
                 :gem_id => 1,
                 :date => Date.new(2014, 6, 2),
                 :value => 30)
    Value.insert(:id => 3,
                 :type => Value::Type::TOTAL_DOWNLOADS,
                 :gem_id => 2,
                 :date => Date.new(2014, 6, 1),
                 :value => 40)
    Value.insert(:id => 4,
                 :type => Value::Type::TOTAL_DOWNLOADS,
                 :gem_id => 2,
                 :date => Date.new(2014, 6, 2),
                 :value => 50)

    DailyDownloadsUpdater.execute(Date.new(2014, 6, 2))

    assert_equal 6, Value.count
  end
end
