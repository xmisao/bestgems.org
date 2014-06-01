require 'date'
require_relative '../database'

class DailyDownloadsUpdater
  def self.execute(date)
    Value.where(:type => Value::Type::TOTAL_DOWNLOADS,
                :date => date)
         .each{|value|
      update_daily_downloads(value)
    }
  end

  def self.update_daily_downloads(value1)
    value2 = Value.where(:type => Value::Type::TOTAL_DOWNLOADS,
                         :date => value1[:date] - 1,
                         :gem_id => value1[:gem_id]).first
    return unless value2

    new_value = {:type => Value::Type::DAILY_DOWNLOADS,
                 :gem_id => value1[:gem_id],
                 :date => value1[:date],
                 :value => value1[:value] - value2[:value]}

    Value.insert_or_update(new_value, :type, :date, :gem_id)
  end
end

if $0 == __FILE__
  date = ARGV[0] || Date.today - 1
  DailyDownloadsUpdater.execute(date)
end
