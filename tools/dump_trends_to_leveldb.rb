# CAUTION!!
# This script require very large memory capacity

require_relative '../lib/database'

case ENV['RACK_ENV']
when 'development'
when 'production'
else
  puts "You should set value 'development'(to use SQLite3) or 'production'(to use PostgreSQL) to RACK_ENV environment variable."
  exit 1
end

require 'logger'
$logger = Logger.new('dump_trends_to_leveldb.log')

class TrendDumper
  def initialize(values_table, rankings_table)
    @values_table, @rankings_table = values_table, rankings_table
  end

  def dump_to_level_db
    total_downloads_map = create_map
    daily_downloads_map = create_map
    total_ranking_map = create_map
    daily_ranking_map = create_map

    @values_table.each{|record|
      case record[:type]
      when Value::Type::TOTAL_DOWNLOADS
        total_downloads_map[record[:gem_id]][record[:date]] = record[:value]
      when Value::Type::DAILY_DOWNLOADS
        daily_downloads_map[record[:gem_id]][record[:date]] = record[:value]
      end
    }

    @rankings_table.each{|record|
      case record[:type]
      when Ranking::Type::TOTAL_RANKING
        total_ranking_map[record[:gem_id]][record[:date]] = record[:ranking]
      when Ranking::Type::DAILY_RANKING
        daily_ranking_map[record[:gem_id]][record[:date]] = record[:ranking]
      end
    }

    all_gem_id = daily_downloads_map.keys

    all_gem_id.each{|gem_id|
      days = daily_downloads_map[gem_id].keys.sort

      td_list = days.each_with_object([]){|day, td_list|
        td_list << TrendData.new(day, total_downloads_map[gem_id][day], total_ranking_map[gem_id][day], daily_downloads_map[gem_id][day], daily_ranking_map[gem_id][day])
      }

      Trend.put(gem_id, *td_list)
    }
  end

  private

  def create_map
    # Map structure
    #
    # gem_id -> date -> a value/ranking
    #
    # map[gem_id][date] #=> a value/ranking

    Hash.new{|h, k| h[k] = {} }
  end
end

class TableFinder
  def self.find(start_date)
    tables = []

    first_day = start_date - (start_date.day - 1)

    (start_date..Date.today).each{|date|
      if date.day == 1
        yyyymm = sprintf('%04d%02d', date.year, date.month)

        values_table_name = "archived_values_#{yyyymm}".to_sym
        rankings_table_name = "archived_rankings_#{yyyymm}".to_sym

        if DB.table_exists?(values_table_name) && DB.table_exists?(rankings_table_name)
          tables << [DB[values_table_name], DB[rankings_table_name]]
        end
      end
    }

    tables << [DB[:values], DB[:rankings]]
  end
end

begin
  TableFinder.find(Date.new(2013, 6, 1)).each{|tables|
    $logger.info "Dump trend data to level db from #{tables.map{|t| t.first_source}}"

    TrendDumper.new(*tables).dump_to_level_db
  }
rescue => e
  $logger.error e
  raise
end
