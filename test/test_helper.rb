module TestHelper
  def self.delete_all
    ReportData.where.delete
    Reports.where.delete
    Statistics.where.delete
    ScrapedData.where.delete
    Value.where.delete
    Ranking.where.delete
    Gems.where.delete

    Trend.all{|k, v|
      Trend.delete_a(k)
    }
  end
end
