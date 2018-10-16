require "date"
require_relative "../database"

class GemsLatestColumnsUpdater
  CHUNK = 1000

  def self.execute(date)
    batch_trace("GemsLatestColumnsUpdater", "execute", [date]) {
      total_downloads_map, daily_downloads_map = fetch_values(date)

      total_ranking_map, daily_ranking_map = fetch_rankings(date)

      all_gem_ids = total_downloads_map.keys.sort

      update_latest(all_gem_ids, total_downloads_map, total_ranking_map, daily_downloads_map, daily_ranking_map, date)
    }
  end

  def self.fetch_values(date)
    batch_trace("GemsLatestColumnsUpdater", "fetch_values") {
      total_downloads_map = {}
      daily_downloads_map = {}

      Value.where(date: date).each { |record|
        case record[:type]
        when Value::Type::TOTAL_DOWNLOADS
          total_downloads_map[record[:gem_id]] = record[:value]
        when Value::Type::DAILY_DOWNLOADS
          daily_downloads_map[record[:gem_id]] = record[:value]
        end
      }

      return total_downloads_map, daily_downloads_map
    }
  end

  def self.fetch_rankings(date)
    batch_trace("GemsLatestColumnsUpdater", "fetch_rankings") {
      total_ranking_map = {}
      daily_ranking_map = {}

      Ranking.where(date: date).each { |record|
        case record[:type]
        when Ranking::Type::TOTAL_RANKING
          total_ranking_map[record[:gem_id]] = record[:ranking]
        when Ranking::Type::DAILY_RANKING
          daily_ranking_map[record[:gem_id]] = record[:ranking]
        end
      }

      return total_ranking_map, daily_ranking_map
    }
  end

  def self.update_latest(all_gem_ids, total_downloads_map, total_ranking_map, daily_downloads_map, daily_ranking_map, date)
    batch_trace("GemsLatestColumnsUpdater", "update_latest") {
      all_gem_ids.each_slice(CHUNK) { |gem_ids|
        DB.transaction do
          gem_ids.each { |gem_id|
            Gems.where(id: gem_id).update(
              latest_total_downloads: total_downloads_map[gem_id],
              latest_total_ranking: total_ranking_map[gem_id],
              latest_daily_downloads: daily_downloads_map[gem_id],
              latest_daily_ranking: daily_ranking_map[gem_id],
              latest_update_date: date,
            )
          }
        end
      }
    }
  end
end

if $0 == __FILE__
  date = ARGV[0] || Date.today - 1
  GemsLatestColumnsUpdater.execute(date)
end
