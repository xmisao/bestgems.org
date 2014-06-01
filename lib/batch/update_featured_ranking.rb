require 'date'
require_relative '../database'

class FeaturedRankingUpdater
  def self.execute(date)
    rank = 1
    last_rank = 1
    last_downloads = 2 ** 63

    Value.where(:type => Value::Type::FEATURED_SCORE,
                :date => date)
         .order(:value)
         .reverse
         .each{|value|
      if value[:value] < last_downloads
        last_rank = rank
        last_downloads = value[:value]
      end
      Ranking.update(Ranking::Type::FEATURED_RANKING,
                     value[:gem_id],
                     value[:date],
                     last_rank) 
      rank += 1
    }
  end
end

if $0 == __FILE__
  date = ARGV[0] || Date.today - 1
  FeaturedRankingUpdater.execute(date)
end
