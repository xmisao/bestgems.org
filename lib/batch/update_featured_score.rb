require 'date'
require_relative '../database'

class FeaturedScoreUpdater
  def self.execute(date)
    Ranking.where(:type => Ranking::Type::DAILY_RANKING,
                  :date => date)
           .order(:ranking)
           .limit(1000)
           .each{|daily_ranking|
      update_featured_score(daily_ranking)
    }
  end

  def self.update_featured_score(daily_ranking)
    total_ranking = Ranking.where(:type => Ranking::Type::TOTAL_RANKING,
                                  :gem_id => daily_ranking[:gem_id],
                                  :date => daily_ranking[:date]).first
    raise 'Database inconsistency.' unless total_ranking

    rank_diff = total_ranking[:ranking] - daily_ranking[:ranking]

    new_value = {:type => Value::Type::FEATURED_SCORE,
                 :gem_id => daily_ranking[:gem_id],
                 :date => daily_ranking[:date],
                 :value => rank_diff}
    Value.insert_or_update(new_value, :type, :gem_id, :date)
  end
end

if $0 == __FILE__
  date = ARGV[0] || Date.today - 1
  FeaturedScoreUpdater.execute(date)
end
