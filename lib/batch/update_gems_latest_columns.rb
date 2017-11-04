require 'date'
require_relative '../database'

class GemsLatestColumnsUpdater
  CHUNK = 1000
  @@logger = Logger.new('update_gems_latest_columns.log')

  def self.execute(date)
    @@logger.info("Start execute (date=#{date})")

    total_downloads_map = {}
    daily_downloads_map = {}
    total_ranking_map = {}
    daily_ranking_map = {}

    @@logger.info('Start fetch values')

    Value.where(date: date).each{|record|
      case record[:type]
      when Value::Type::TOTAL_DOWNLOADS
        total_downloads_map[record[:gem_id]] = record[:value]
      when Value::Type::DAILY_DOWNLOADS
        daily_downloads_map[record[:gem_id]] = record[:value]
      end
    }

    @@logger.info('End fetch values')

    @@logger.info('Start fetch rankings')

    Ranking.where(date: date).each{|record|
      case record[:type]
      when Ranking::Type::TOTAL_RANKING
        total_ranking_map[record[:gem_id]] = record[:ranking]
      when Ranking::Type::DAILY_RANKING
        daily_ranking_map[record[:gem_id]] = record[:ranking]
      end
    }

    @@logger.info('End fetch rankings')

    all_gem_ids = daily_downloads_map.keys.sort

    @@logger.info('Start put trend data')

    all_gem_ids.each_slice(CHUNK){|gem_ids|
      @@logger.info("Update trend data for gem_id from #{gem_ids.first}")

      DB.transaction do
        gem_ids.each{|gem_id|
          Gems.where(id: gem_id).update(
            latest_total_downloads: total_downloads_map[gem_id],
            latest_total_ranking: total_ranking_map[gem_id],
            latest_daily_downloads: daily_downloads_map[gem_id],
            latest_daily_ranking: daily_ranking_map[gem_id],
            latest_update_date: date
          )
        }
      end
    }

    @@logger.info('End put trend data')

    @@logger.info('End execute')
  rescue => e
    @@logger.error(e)
    raise
  end
end

if $0 == __FILE__
  date = ARGV[0] || Date.today - 1
  GemsLatestColumnsUpdater.execute(date)
end
