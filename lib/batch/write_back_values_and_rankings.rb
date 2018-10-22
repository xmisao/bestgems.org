require_relative "../database"

class WriteBackValuesAndRankings
  def initialize(date)
    batch_trace("WriteBackValuesAndRankings", "initialize", [date]) {
      @date = date
    }
  end

  def execute()
    batch_trace("WriteBackValuesAndRankings", "execute", []) {
      Gems.where(latest_update_date: @date).paged_each.each_with_index{|gem, i|
        BatchLogger.info(type: :progress, i: i) if i % 1000 == 0

        DB.transaction{
          insert_total_downloads(gem)
          insert_daily_downloads(gem)
          insert_total_ranking(gem)
          insert_daily_ranking(gem)
        }
      }
    }
  end

  def insert_total_downloads(gem)
    return unless gem.latest_total_downloads

    Value.insert(
      :type => Value::Type::TOTAL_DOWNLOADS,
      :gem_id => gem.id,
      :date => @date,
      :value => gem.latest_total_downloads
    )
  end

  def insert_daily_downloads(gem)
    return unless gem.latest_daily_downloads

    Value.insert(
      :type => Value::Type::DAILY_DOWNLOADS,
      :gem_id => gem.id,
      :date => @date,
      :value => gem.latest_daily_downloads
    )
  end

  def insert_total_ranking(gem)
    return unless gem.latest_total_ranking

    Ranking.insert(
      :type => Ranking::Type::TOTAL_RANKING,
      :gem_id => gem.id,
      :date => @date,
      :ranking => gem.latest_total_ranking
    )
  end

  def insert_daily_ranking(gem)
    return unless gem.latest_daily_ranking

    Ranking.insert(
      :type => Ranking::Type::DAILY_RANKING,
      :gem_id => gem.id,
      :date => @date,
      :ranking => gem.latest_daily_ranking
    )
  end
end

if $0 == __FILE__
  date = Date.parse(ARGV[0])
  WriteBackValuesAndRankings.new(date).execute
end
