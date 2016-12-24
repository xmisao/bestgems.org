require 'date'
require_relative '../database'

class TotalRankingUpdater
  def self.execute(date)
    clear_total_ranking(date)
    total_ranking = generate_total_ranking(date)
    update_total_ranking(total_ranking)
  end

  def self.clear_total_ranking(date)
    Ranking.where(:type => Ranking::Type::TOTAL_RANKING, :date => date).delete
  end

  def self.generate_total_ranking(date)
    total_ranking = []
    rank = 1
    last_rank = 1
    last_downloads = 2 ** 63

    Value.where(:type => Value::Type::TOTAL_DOWNLOADS,
                :date => date)
         .order(:value)
         .reverse
         .each{|value|
      if value[:value] < last_downloads
        last_rank = rank
        last_downloads = value[:value]
      end

      record = {:type => Ranking::Type::TOTAL_RANKING,
                :gem_id => value[:gem_id],
                :date => value[:date],
                :ranking => last_rank}
      total_ranking << record

      rank += 1
    }

    total_ranking
  end

  def self.update_total_ranking(total_ranking)
    total_ranking.each_slice(SLICE_SIZE) do |sliced_data|
      Ranking.multi_insert(sliced_data)
    end
  end
end

if $0 == __FILE__
  date = ARGV[0] || Date.today - 1
  TotalRankingUpdater.execute(date)
end
