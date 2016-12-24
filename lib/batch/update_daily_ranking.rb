require 'date'
require_relative '../database'

class DailyRankingUpdater
  def self.execute(date)
    clear_daily_ranking(date)
    daily_ranking = generate_daily_ranking(date)
    update_daily_ranking(daily_ranking)
  end

  def self.clear_daily_ranking(date)
    Ranking.where(:type => Ranking::Type::DAILY_RANKING, :date => date).delete
  end

  def self.generate_daily_ranking(date)
    daily_ranking = []
    rank = 1
    last_rank = 1
    last_downloads = 2 ** 63

    Value.where(:type => Value::Type::DAILY_DOWNLOADS,
                :date => date)
         .order(:value)
         .reverse
         .each{|value|
      if value[:value] < last_downloads
        last_rank = rank
        last_downloads = value[:value]
      end
      record = {:type => Ranking::Type::DAILY_RANKING,
                :gem_id => value[:gem_id],
                :date => value[:date],
                :ranking => last_rank}
      daily_ranking << record
      rank += 1
    }
    daily_ranking
  end

  def self.update_daily_ranking(daily_ranking)
    daily_ranking.each_slice(SLICE_SIZE) do |sliced_data|
      Ranking.multi_insert(sliced_data)
    end
  end
end

if $0 == __FILE__
  date = ARGV[0] || Date.today - 1
  DailyRankingUpdater.execute(date)
end
