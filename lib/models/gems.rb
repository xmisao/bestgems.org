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
end
