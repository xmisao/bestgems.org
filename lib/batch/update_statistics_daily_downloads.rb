require "date"
require_relative "../database"

class StatisticsDailyDownloadsUpdater
  def self.execute(date)
    batch_trace("StatisticsDailyDownloadsUpdater", "execute", [date]) {
      daily_downloads = Value.where(:type => Value::Type::DAILY_DOWNLOADS,
                                    :date => date).sum(:value)

      row = {:type => Statistics::Type::DAILY_DOWNLOADS,
             :date => date,
             :value => daily_downloads}

      Statistics.insert(row) # TODO: Idempotence
    }
  end
end

if $0 == __FILE__
  date = ARGV[0] || Date.today - 1
  StatisticsDailyDownloadsUpdater.execute(date)
end
