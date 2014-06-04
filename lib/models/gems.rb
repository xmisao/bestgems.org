class Gems < Sequel::Model
  def self.search(date, query)
    like = nil
    query.split(/\s+/)[0..4].each{|q|
      l = (Sequel.ilike(:name, "%#{q}%") | Sequel.ilike(:summary, "%#{q}%"))
      like ? like = like & l : like = l
    }
    DB.from(Gems.where(like).as(:G))
      .join(
        Ranking.where(:type => Ranking::Type::TOTAL_RANKING,
                      :date => date).as(:R),
        :G__id => :R__gem_id)
      .join(
        Value.where(:type => Value::Type::TOTAL_DOWNLOADS,
                    :date => date).as(:V),
        :G__id => :V__gem_id)
      .order(:R__ranking)
      .select(:G__name, :G__summary, :R__ranking, Sequel.as(:V__value, :downloads))
  end

  def total_downloads_trends()
    Value.where(:gem_id => self[:id], :type => Value::Type::TOTAL_DOWNLOADS)
         .order(:date)
         .select(:date, Sequel.as(:value, :downloads))
  end

  def daily_downloads_trends()
    Value.where(:gem_id => self[:id], :type => Value::Type::DAILY_DOWNLOADS)
         .order(:date)
         .select(:date, Sequel.as(:value, :downloads))
  end

  def downloads_trends()
    DB.from(total_downloads_trends.as(:T))
      .left_outer_join(daily_downloads_trends.as(:D), :T__date => :D__date) 
      .order(:T__date)
      .select(:T__date, Sequel.as(:T__downloads, :total_downloads), Sequel.as(:D__downloads, :daily_downloads))
  end

  def total_ranking_trends()
    Ranking.where(:gem_id => self[:id], :type => Ranking::Type::TOTAL_RANKING)
           .order(:date)
           .select(:date, :ranking)
  end

  def daily_ranking_trends()
    Ranking.where(:gem_id => self[:id], :type => Ranking::Type::DAILY_RANKING)
           .order(:date)
           .select(:date, :ranking)
  end

  def ranking_trends()
    DB.from(total_ranking_trends.as(:T))
      .left_outer_join(daily_ranking_trends.as(:D), :T__date => :D__date) 
      .order(:T__date)
      .select(:T__date, Sequel.as(:T__ranking, :total_ranking), Sequel.as(:D__ranking, :daily_ranking))
  end

  def info(date)
    Gems.where(:name => self[:name])
        .join(Value.where(:type => Value::Type::TOTAL_DOWNLOADS,
                          :date => date).as(:TD),
              :gems__id => :TD__gem_id)
        .join(Value.where(:type => Value::Type::DAILY_DOWNLOADS,
                          :date => date).as(:DD),
              :gems__id => :DD__gem_id)
        .join(Ranking.where(:type => Ranking::Type::TOTAL_RANKING,
                            :date => date).as(:TR),
              :gems__id => :TR__gem_id)
        .join(Ranking.where(:type => Ranking::Type::DAILY_RANKING,
                            :date => date).as(:DR),
              :gems__id => :DR__gem_id)
        .select(:gems__name,
                :gems__summary,
                :gems__version,
                Sequel.as(:TD__value, :total_downloads),
                Sequel.as(:DD__value, :daily_downloads),
                Sequel.as(:TR__ranking, :total_ranking),
                Sequel.as(:DR__ranking, :daily_ranking))
        .first
  end
end
