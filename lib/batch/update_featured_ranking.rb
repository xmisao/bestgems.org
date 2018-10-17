require "date"
require_relative "../database"

class FeaturedRankingUpdater
  def self.execute(date)
    batch_trace("FeaturedRankingUpdater", "execute", [date]) {
      clear_featured_ranking(date)
      featured_ranking = generate_featured_ranking(date)
      update_featured_ranking(featured_ranking)
    }
  end

  def self.clear_featured_ranking(date)
    Ranking.where(:type => Ranking::Type::FEATURED_RANKING, :date => date).delete
  end

  def self.generate_featured_ranking(date)
    featured_ranking = []
    rank = 1
    last_rank = 1
    last_downloads = 2 ** 63

    Value.where(:type => Value::Type::FEATURED_SCORE,
                :date => date)
         .order(:value)
         .reverse
         .each { |value|
      if value[:value] < last_downloads
        last_rank = rank
        last_downloads = value[:value]
      end

      record = {:type => Ranking::Type::FEATURED_RANKING,
                :gem_id => value[:gem_id],
                :date => value[:date],
                :ranking => last_rank}
      featured_ranking << record

      rank += 1
    }
    featured_ranking
  end

  def self.update_featured_ranking(featured_ranking)
    Ranking.multi_insert(featured_ranking)
  end
end

if $0 == __FILE__
  date = ARGV[0] || Date.today - 1
  FeaturedRankingUpdater.execute(date)
end
