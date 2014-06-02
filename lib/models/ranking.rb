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

  def self.total(date)
    self.select{[name, summary, ranking, value.as(downloads)]}
        .join(:gems, :gems__id => :rankings__gem_id)
        .join(:values, :values__gem_id => :rankings__gem_id)
        .where(:rankings__date => date, :rankings__type => Ranking::Type::TOTAL_RANKING)
        .where(:values__date => date, :values__type => Value::Type::TOTAL_DOWNLOADS)
        .order(:ranking)
  end
end
