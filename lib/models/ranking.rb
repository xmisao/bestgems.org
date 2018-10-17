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

  def self.total(date, *limit)
    Gems.where(latest_update_date: date).order(:latest_total_ranking).limit(*limit).select(
      :name,
      :summary,
      Sequel.as(:latest_total_ranking, :ranking),
      Sequel.as(:latest_total_downloads, :downloads)
    )
  end

  def self.total_count(date)
    if daily_summary = DailySummary.fetch(date)
      daily_summary[:ranking_total_count]
    else
      total_count0(date)
    end
  end

  def self.total_count0(date)
    Ranking.where(:type => Ranking::Type::TOTAL_RANKING,
                  :date => date).count
  end

  def self.daily(date, *limit)
    Gems.where(latest_update_date: date).order(:latest_daily_ranking).limit(*limit).select(
      :name,
      :summary,
      Sequel.as(:latest_daily_ranking, :ranking),
      Sequel.as(:latest_daily_downloads, :downloads)
    )
  end

  def self.daily_count(date)
    if daily_summary = DailySummary.fetch(date)
      daily_summary[:ranking_daily_count]
    else
      daily_count0(date)
    end
  end

  def self.daily_count0(date)
    Ranking.where(:type => Ranking::Type::DAILY_RANKING,
                  :date => date).count
  end

  def self.featured(date, *limit)
    featured_ranking = Ranking.where(
      :type => Ranking::Type::FEATURED_RANKING,
      :date => date,
    )
      .order(:ranking)
      .limit(*limit)
      .select(:gem_id, :ranking)

    gem_info = featured_ranking.map { |ranking| {gem_id: ranking[:gem_id], featured_ranking: ranking[:ranking]} }

    Gems.where(id: gem_info.map { |info| info[:gem_id] }).map { |gem|
      {
        name: gem[:name],
        summary: gem[:summary],
        score: gem[:latest_total_ranking] - gem[:latest_daily_ranking],
        ranking: gem_info.select { |gi| gi[:gem_id] == gem[:id] }.first[:featured_ranking],
        total_ranking: gem[:latest_total_ranking],
        daily_ranking: gem[:latest_daily_ranking],
      }
    }.sort_by { |gem| gem[:ranking] }
  end

  def self.featured_count(date)
    Ranking.where(:type => Ranking::Type::FEATURED_RANKING,
                  :date => date).count
  end
end
