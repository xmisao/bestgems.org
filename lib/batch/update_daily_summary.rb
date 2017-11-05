require 'date'
require_relative '../database'

class DailySummaryUpdater
  def self.execute(date)
    DB.transaction do
      if DailySummary.where(date: date).first
        DailySummary.where(date: date).update(
          date: date,
          ranking_total_count: Ranking.total_count0(date),
          ranking_daily_count: Ranking.daily_count0(date)
        )
      else
        DailySummary.insert(
          date: date,
          ranking_total_count: Ranking.total_count0(date),
          ranking_daily_count: Ranking.daily_count0(date)
        )
      end
    end
  end
end

if $0 == __FILE__
  date = ARGV[0] || Date.today - 1
  DailySummaryUpdater.execute(date)
end
