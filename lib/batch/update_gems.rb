require "date"
require_relative "../database"

class GemsUpdater
  def self.execute(date)
    batch_trace("GemsUpdater", "execute", [date]) {
      ScrapedData.where(:date => date).order(:name).each { |data|
        update_gem_from_scraped_data(data)
      }
    }
  end

  def self.update_gem_from_scraped_data(data)
    new_gem = {:name => data[:name],
               :version => data[:version],
               :summary => data[:summary]}
    Gems.insert_or_update(new_gem, :name)
  end
end

if $0 == __FILE__
  date = ARGV[0] || Date.today - 1
  GemsUpdater.execute(date)
end
