class DailySummary < Sequel::Model(:daily_summaries)
  def self.fetch(date)
    self.where(date: date).first
  end
end
