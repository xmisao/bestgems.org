require 'date'
require_relative '../database'

class TrendUpdater
  @@logger = Logger.new('update_trend.log')

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

    all_gem_id = daily_downloads_map.keys.sort

    @@logger.info('Start put trend data')

    all_gem_id.each{|gem_id|
      @@logger.info("Put trend data for gem_id #{gem_id}") if gem_id % 100 == 0

      td = TrendData.new(date, total_downloads_map[gem_id], total_ranking_map[gem_id], daily_downloads_map[gem_id], daily_ranking_map[gem_id])
      Trend.put(gem_id, td)
    }

    @@logger.info('End put trend data')

    @@logger.info('End execute')
  rescue => e
    @@logger.error(e)
    raise
  end
end

if $0 == __FILE__
  date = Date.parse(ARGV[0]) || Date.today - 1
  TrendUpdater.execute(date)
end
