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

  def self.total(date, limit)
    DB.from(Ranking.where(:type => Ranking::Type::TOTAL_RANKING,
                          :date => date)
                   .order(:ranking)
                   .limit(limit)
                   .as(:R))
      .join(
        Value.where(:type => Value::Type::TOTAL_DOWNLOADS,
                    :date => date).as(:V),
        :R__gem_id => :V__gem_id)
      .join(:gems, :gems__id => :R__gem_id)
      .select(:gems__name, :gems__summary, :R__ranking, Sequel.as(:V__value, :downloads))
  end

  def self.daily(date, limit)
    DB.from(Ranking.where(:type => Ranking::Type::DAILY_RANKING,
                          :date => date)
                   .order(:ranking)
                   .limit(limit)
                   .as(:R))
      .join(
        Value.where(:type => Value::Type::DAILY_DOWNLOADS,
                    :date => date).as(:V),
        :R__gem_id => :V__gem_id)
      .join(:gems, :gems__id => :R__gem_id)
      .select(:gems__name, :gems__summary, :R__ranking, Sequel.as(:V__value, :downloads))
  end

  def self.featured(date, limit)
    DB.from(Ranking.where(:type => Ranking::Type::FEATURED_RANKING,
                          :date => date)
                   .order(:ranking)
                   .limit(limit)
                   .as(:RF))
      .join(:gems, :gems__id => :RF__gem_id)
      .join(
        Value.where(:type => Value::Type::FEATURED_SCORE,
                    :date => date).as(:V),
        :RF__gem_id => :V__gem_id)
      .join(
        Ranking.where(:type => Ranking::Type::TOTAL_RANKING,
                      :date => date)
               .as(:RT),
        :RF__gem_id => :RT__gem_id)
      .join(
        Ranking.where(:type => Ranking::Type::DAILY_RANKING,
                      :date => date)
               .as(:RD),
        :RD__gem_id => :RT__gem_id)
      .select(:gems__name, :gems__summary, :RF__ranking, Sequel.as(:V__value, :score), Sequel.as(:RT__ranking, :total_ranking), Sequel.as(:RD__ranking, :daily_ranking))
=begin
=end
=begin
=end
  end
end
