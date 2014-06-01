require 'date'
require_relative '../database'

class TotalDownloadsUpdater
  def self.execute(date)
    ScrapedData.where(:date => date).order(:name).each{|data|
      update_total_downloads_from_scraped_data(data)
    }
  end

  def self.update_total_downloads_from_scraped_data(data)
    gem = Gems.where(:name => data[:name]).first
    raise 'Database inconsistency.' unless gem

    new_value = {:type => Value::Type::TOTAL_DOWNLOADS,
                 :gem_id => gem[:id],
                 :date => data[:date],
                 :value => data[:downloads]}
    Value.insert_or_update(new_value, :type, :gem_id, :date)
  end
end

if $0 == __FILE__
  date = ARGV[0] || Date.today - 1
  TotalDownloadsUpdater.execute(date)
end
