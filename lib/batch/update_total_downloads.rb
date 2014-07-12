require 'date'
require_relative '../database'

class TotalDownloadsUpdater
  def self.execute(date)
    clear_total_downloads(date)
    total_downloads = generate_total_downloads_from_scraped_data(date)
    update_total_downloads(total_downloads)
  end

  def self.clear_total_downloads(date)
    Value.where(:type => Value::Type::TOTAL_DOWNLOADS, :date => date).delete
  end

  def self.generate_total_downloads_from_scraped_data(date)
    total_downloads = []
    ScrapedData.where(:date => date).order(:name).each{|data|
      gem = Gems.where(:name => data[:name]).first
      raise 'Database inconsistency.' unless gem

      record = {:type => Value::Type::TOTAL_DOWNLOADS,
                :gem_id => gem[:id],
                :date => data[:date],
                :value => data[:downloads]}
      total_downloads << record
    }
    total_downloads
  end

  def self.update_total_downloads(total_downloads)
    Value.multi_insert(total_downloads)
  end
end

if $0 == __FILE__
  date = ARGV[0] || Date.today - 1
  TotalDownloadsUpdater.execute(date)
end
