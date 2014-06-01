class Ranking < Sequel::Model
  module Type
    TOTAL_RANKING = 0
    DAILY_RANKING = 1
    FEATURED_RANKING = 2
  end

  def self.update(type, gem_id, date, rank)
    new_ranking = {:type => type,
                   :gem_id => gem_id,
                   :date => date,
                   :ranking => rank}
    Ranking.insert_or_update(new_ranking, :type, :gem_id, :date)
  end
end
