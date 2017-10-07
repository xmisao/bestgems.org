require 'minitest/autorun'
require 'database'

class TestTrendDataSet < MiniTest::Unit::TestCase
  def test_downloads_trends
    tds = TrendDataSet.new([TrendData.new(Date.new(2017, 10, 1), 1, 2, 3, 4)])

    assert_equal [{date: Date.new(2017, 10, 1), total_downloads: 1, daily_downloads: 3}], tds.downloads_trends
  end

  def test_ranking_trends
    tds = TrendDataSet.new([TrendData.new(Date.new(2017, 10, 1), 1, 2, 3, 4)])

    assert_equal [{date: Date.new(2017, 10, 1), total_ranking: 2, daily_ranking: 4}], tds.ranking_trends
  end
end
