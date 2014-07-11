require 'minitest/unit'
require 'database'
require 'batch/update_total_downloads'
require_relative '../run_migration'

class TestUpdateTotalDownloads < MiniTest::Unit::TestCase
  def setup
    ScrapedData.where.delete
    Value.where.delete
    Gems.where.delete
  end

  def test_update_total_downloads_from_scraped_data
    ScrapedData.insert(:id => 1,
                       :date => Date.new(2014, 6, 1),
                       :name => 'foo',
                       :downloads => 42)
    Gems.insert(:id => 1,
                :name => 'foo')

    data = ScrapedData[1]
    value = TotalDownloadsUpdater.update_total_downloads_from_scraped_data(data)

    assert_equal Value::Type::TOTAL_DOWNLOADS, value[:type]
    assert_equal 1, value[:gem_id]
    assert_equal Date.new(2014, 6, 1), value[:date]
    assert_equal 42, value[:value]
  end

  def test_execute
    ScrapedData.insert(:id => 1,
                       :date => Date.new(2014, 6, 1),
                       :name => 'foo',
                       :downloads => 42)
    ScrapedData.insert(:id => 2,
                       :date => Date.new(2014, 6, 1),
                       :name => 'bar',
                       :downloads => 84)
    Gems.insert(:id => 1,
                :name => 'foo')
    Gems.insert(:id => 2,
                :name => 'bar')

    TotalDownloadsUpdater.execute(Date.new(2014, 6, 1))

    assert_equal 2, Value.count
  end
end
