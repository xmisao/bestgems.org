require 'date'
require_relative '../database'

class StatisticsTotalDownloadsUpdater
  def self.execute(date)
    total_downloads = Value.where(:type => Value::Type::TOTAL_DOWNLOADS,
                                  :date => date).sum(:value)

    row = {:type => Statistics::Type::TOTAL_DOWNLOADS,
           :date => date,
           :value => total_downloads}

    Statistics.insert(row)
  end
end

if $0 == __FILE__
  date = ARGV[0] || Date.today - 1
  StatisticsTotalDownloadsUpdater.execute(date)
end
