require "minitest/autorun"
require "database"
require "batch/scraping_all_gems"
require_relative "../run_migration"
require_relative "../test_helper"

class TestScraper < Minitest::Test
  def setup
    TestHelper.delete_all
  end

  def test_cleaning_gems_data()
    ScrapedData.insert(name: "foo", version: "1.0.0", summary: "foo is ...", downloads: 123, date: "2018-10-14")
    ScrapedData.insert(name: "foo", version: "1.0.0", summary: "foo is ...", downloads: 123, date: "2018-10-15")
    ScrapedData.insert(name: "foo", version: "1.0.0", summary: "foo is ...", downloads: 123, date: "2018-10-16")
    Master.insert(date: "2018-10-14")

    date = Date.new(2018, 10, 15)
    Scraper.cleaning_gems_data(date)

    assert_equal 1, ScrapedData.count
  end

  def test_scraping_gems_data()
    gem = Scraper.scraping_gems_data("A", 1).first
    assert gem[:name]
    assert gem[:version]
    assert gem[:summary]
    assert gem[:downloads]
  end

  def test_save_gems_data()
    gem = {:name => "foo",
           :version => "1.0",
           :summary => "Awesome gem.",
           :downloads => 42}
    date = Date.new(2014, 6, 1)

    Scraper.save_gems_data([gem], date)

    data = ScrapedData.first
    assert_equal "foo", data[:name]
    assert_equal "1.0", data[:version]
    assert_equal "Awesome gem.", data[:summary]
    assert_equal 42, data[:downloads]
    assert_equal Date.new(2014, 6, 1), data[:date]
  end
end
