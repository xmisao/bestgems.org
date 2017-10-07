class TrendUpdater
  def self.execute(date)
    Gems.each{|gem|
      trend = gem.get_trend_data_from_rdb(date)
      gem.put_trend_data(trend) if trend
    }
  end
end

if $0 == __FILE__
  date = Date.parse(ARGV[0]) || Date.today - 1
  TrendUpdater.execute(date)
end
