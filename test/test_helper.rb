module TestHelper
  def self.delete_all
    ReportData.dataset.delete
    Reports.dataset.delete
    Statistics.dataset.delete
    ScrapedData.dataset.delete
    Value.dataset.delete
    Ranking.dataset.delete
    Gems.dataset.delete
    DailySummary.dataset.delete
    Master.dataset.delete

    Trend.all { |k, v|
      Trend.delete_a(k)
    }
  end
end
