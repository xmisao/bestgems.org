require 'minitest/unit'
require 'database'
require 'batch/scraping_all_gems'
require_relative '../run_migration'

class TestScraper < MiniTest::Unit::TestCase
  def test_scraping_num_of_gems()
    num = Scraper.scraping_num_of_gems('A')
    assert num
  end

  def test_scraping_gems_data()
    gem = Scraper.scraping_gems_data('A', 1).first
    assert gem[:name]
    assert gem[:version]
    assert gem[:summary]
    assert gem[:downloads]
  end

  def test_save_gem_data()
    ScrapedData.where.delete

    gem = {:name => 'foo',
           :version => '1.0',
           :summary => 'Awesome gem.',
           :downloads => 42}
    date = Date.new(2014, 6, 1)

    Scraper.save_gem_data(gem, date)

    data = ScrapedData.first
    assert_equal 'foo', data[:name]
    assert_equal '1.0', data[:version]
    assert_equal 'Awesome gem.', data[:summary]
    assert_equal 42, data[:downloads]
    assert_equal Date.new(2014, 6, 1), data[:date]
  end
end
