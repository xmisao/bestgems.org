require "date"
require_relative "../database"

class DailyDownloadsUpdater
  def self.execute(date)
    batch_trace("DailyDownloadsUpdater", "execute", [date]) {
      clear_daily_downloads(date)
      daily_downloads = generate_daily_downloads(date)
      update_daily_downloads(daily_downloads)
    }
  end

  def self.clear_daily_downloads(date)
    Value.where(:type => Value::Type::DAILY_DOWNLOADS, :date => date).delete
  end

  def self.generate_daily_downloads(date)
    daily_downloads = []
    Value.where(:type => Value::Type::TOTAL_DOWNLOADS,
                :date => date)
         .each { |value1|
      value2 = Value.where(:type => Value::Type::TOTAL_DOWNLOADS,
                           :date => value1[:date] - 1,
                           :gem_id => value1[:gem_id]).first
      next unless value2

      record = {:type => Value::Type::DAILY_DOWNLOADS,
                :gem_id => value1[:gem_id],
                :date => value1[:date],
                :value => value1[:value] - value2[:value]}
      daily_downloads << record
    }
    daily_downloads
  end

  def self.update_daily_downloads(daily_downloads)
    daily_downloads.each_slice(SLICE_SIZE) do |sliced_data|
      Value.multi_insert(sliced_data)
    end
  end
end

if $0 == __FILE__
  date = ARGV[0] || Date.today - 1
  DailyDownloadsUpdater.execute(date)
end
