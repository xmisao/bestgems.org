require 'date'
require_relative '../database'

class FeaturedScoreUpdater
  def self.execute(date)
    clear_featured_score(date)
    featured_score = generate_featured_score(date)
    update_featured_score(featured_score)
  end

  def self.clear_featured_score(date)
    Value.where(:type => Value::Type::FEATURED_SCORE, :date => date).delete
  end

  def self.generate_featured_score(date)
    featured_score = []
    Ranking.where(:type => Ranking::Type::DAILY_RANKING,
                  :date => date)
           .order(:ranking)
           .limit(1000)
           .each{|daily_ranking|
      total_ranking = Ranking.where(:type => Ranking::Type::TOTAL_RANKING,
                                    :gem_id => daily_ranking[:gem_id],
                                    :date => daily_ranking[:date]).first
      raise 'Database inconsistency.' unless total_ranking

      rank_diff = total_ranking[:ranking] - daily_ranking[:ranking]

      record = {:type => Value::Type::FEATURED_SCORE,
                   :gem_id => daily_ranking[:gem_id],
                   :date => daily_ranking[:date],
                   :value => rank_diff}
      featured_score << record
    }
    featured_score
  end

  def self.update_featured_score(featured_score)
    Value.multi_insert(featured_score)
  end
end

if $0 == __FILE__
  date = ARGV[0] || Date.today - 1
  FeaturedScoreUpdater.execute(date)
end
