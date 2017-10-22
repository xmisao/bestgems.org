class Gems < Sequel::Model
  def self.search(date, query)
    like_clause = query.split(/\s+/)[0..4].inject(nil){|like_clause, q|
      cond = (Sequel.ilike(:name, "%#{q}%") | Sequel.ilike(:summary, "%#{q}%"))
      like_clause ? like_clause & cond : cond
    }

    Gems.where(latest_update_date: date).where(like_clause).order(:latest_total_ranking)
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

  def latest_trend(date)
    if date == self[:latest_update_date]
      {
        total_downloads: self[:latest_total_downloads],
        daily_downloads: self[:latest_daily_downloads],
        total_ranking: self[:latest_total_ranking],
        daily_ranking: self[:latest_daily_ranking]
      }
    elsif date < self[:latest_update_date]
      # This state will occure when running update_gems_latest_columns.rb
      # Should failback to old means

      info(date)
    else
      {
        total_downloads: nil,
        daily_downloads: nil,
        total_ranking: nil,
        daily_ranking: nil
      }
    end
  end

  def info(date)
    Gems.where(:name => self[:name])
        .join(Value.where(:type => Value::Type::TOTAL_DOWNLOADS,
                          :date => date).as(:TD),
              :gems__id => :TD__gem_id)
        .left_join(Value.where(:type => Value::Type::DAILY_DOWNLOADS,
                               :date => date).as(:DD),
                   :gems__id => :DD__gem_id)
        .join(Ranking.where(:type => Ranking::Type::TOTAL_RANKING,
                            :date => date).as(:TR),
              :gems__id => :TR__gem_id)
        .left_join(Ranking.where(:type => Ranking::Type::DAILY_RANKING,
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

  def get_trend_data_from_rdb(date)
    total_downloads = Value.where(gem_id: id, type: Value::Type::TOTAL_DOWNLOADS, date: date).get(:value)
    daily_downloads = Value.where(gem_id: id, type: Value::Type::DAILY_DOWNLOADS, date: date).get(:value)
    total_ranking = Ranking.where(gem_id: id, type: Ranking::Type::TOTAL_RANKING, date: date).get(:ranking)
    daily_ranking = Ranking.where(gem_id: id, type: Ranking::Type::DAILY_RANKING, date: date).get(:ranking)

    TrendData.new(date, total_downloads, total_ranking, daily_downloads, daily_ranking) if total_downloads || total_ranking || daily_downloads || daily_ranking
  end

  def put_trend_data(*td_list)
    Trend.put(id, *td_list)
  end

  def get_trend_data()
    Trend.get(id)
  end
end
