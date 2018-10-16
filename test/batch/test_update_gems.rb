require "minitest/autorun"
require "database"
require "batch/update_gems"
require_relative "../run_migration"
require_relative "../test_helper"

class TestUpdateGems < Minitest::Test
  def setup
    TestHelper.delete_all
  end

  def test_update_gem_from_scraped_data
    id = ScrapedData.insert(:date => Date.new(2014, 6, 1),
                            :name => "foo",
                            :version => "1.0",
                            :summary => "awesome gem.",
                            :downloads => 42)

    data = ScrapedData[id]
    gem = GemsUpdater.update_gem_from_scraped_data(data)

    assert_equal "foo", gem[:name]
    assert_equal "1.0", gem[:version]
    assert_equal "awesome gem.", gem[:summary]
  end

  def test_execute
    ScrapedData.insert(:date => Date.new(2014, 6, 1),
                       :name => "foo",
                       :version => "1.0",
                       :summary => "awesome gem.",
                       :downloads => 42)
    ScrapedData.insert(:date => Date.new(2014, 6, 1),
                       :name => "bar",
                       :version => "2.0",
                       :summary => "special gem.",
                       :downloads => 84)

    GemsUpdater.execute(Date.new(2014, 6, 1))

    assert_equal 2, Gems.count
  end
end
