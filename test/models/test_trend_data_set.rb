require "minitest/autorun"
require "database"

class TestTrendDataSet < Minitest::Test
  def test_downloads_trends
    tds = TrendDataSet.new([TrendData.new(Date.new(2017, 10, 1), 1, 2, 3, 4)])

    assert_equal [{date: Date.new(2017, 10, 1), total_downloads: 1, daily_downloads: 3}], tds.downloads_trends
  end

  def test_ranking_trends
    tds = TrendDataSet.new([TrendData.new(Date.new(2017, 10, 1), 1, 2, 3, 4)])

    assert_equal [{date: Date.new(2017, 10, 1), total_ranking: 2, daily_ranking: 4}], tds.ranking_trends
  end

  def test_total_downloads
    tds = TrendDataSet.new([TrendData.new(Date.new(2017, 10, 1), 1, 2, 3, 4)])

    assert_equal [{date: Date.new(2017, 10, 1), total_downloads: 1}], tds.total_downloads
  end

  def test_daily_downloads
    tds = TrendDataSet.new([TrendData.new(Date.new(2017, 10, 1), 1, 2, 3, 4)])

    assert_equal [{date: Date.new(2017, 10, 1), daily_downloads: 3}], tds.daily_downloads
  end

  def test_total_ranking
    tds = TrendDataSet.new([TrendData.new(Date.new(2017, 10, 1), 1, 2, 3, 4)])

    assert_equal [{date: Date.new(2017, 10, 1), total_ranking: 2}], tds.total_ranking
  end

  def test_daily_ranking
    tds = TrendDataSet.new([TrendData.new(Date.new(2017, 10, 1), 1, 2, 3, 4)])

    assert_equal [{date: Date.new(2017, 10, 1), daily_ranking: 4}], tds.daily_ranking
  end
end
