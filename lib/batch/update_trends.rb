require "date"
require_relative "../database"

class TrendUpdater
  def self.execute(date)
    batch_trace("TrendUpdater", "execute", [date]) {
      total_downloads_map, daily_downloads_map = fetch_values(date)

      total_ranking_map, daily_ranking_map = fetch_rankings(date)

      all_gem_ids = total_downloads_map.keys.sort

      update_trends(all_gem_ids, total_downloads_map, total_ranking_map, daily_downloads_map, daily_ranking_map, date)
    }
  end

  def self.fetch_values(date)
    batch_trace("TrendUpdater", "fetch_values") {
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
    batch_trace("TrendUpdater", "fetch_rankings") {
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

  def self.update_trends(all_gem_ids, total_downloads_map, total_ranking_map, daily_downloads_map, daily_ranking_map, date)
    batch_trace("TrendUpdater", "update_trends") {
      all_gem_ids.each_with_index { |gem_id, i|
        BatchLogger.info(type: "progress", class: "TrendUpdater", method: "update_trends", i: i) if i % 1000 == 0

        td = TrendData.new(date, total_downloads_map[gem_id], total_ranking_map[gem_id], daily_downloads_map[gem_id], daily_ranking_map[gem_id])
        Trend.put(gem_id, td)
      }
    }
  end
end

if $0 == __FILE__
  date ||= Date.parse(ARGV[0]) if ARGV[0]
  date ||= Date.today - 1
  TrendUpdater.execute(date)
end
