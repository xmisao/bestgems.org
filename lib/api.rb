def total_ranking_api(date, start, count)
  Ranking.total(date, count, start).map{|record|
    {:date => record[:date].to_s,
     :name => record[:name],
     :summary => record[:summary],
     :total_ranking => record[:ranking],
     :total_downloads => record[:downloads]}
  }
end

def daily_ranking_api(date, start, count)
  Ranking.daily(date, count, start).map{|record|
    {:date => record[:date].to_s,
     :name => record[:name],
     :summary => record[:summary],
     :daily_ranking => record[:ranking],
     :daily_downloads => record[:downloads]}
  }
end

def featured_gems_ranking_api(date, start, count)
  Ranking.featured(date, count, start).map{|record|
    {:date => record[:date].to_s,
     :name => record[:name],
     :summary => record[:summary],
     :featured_gem_ranking => record[:ranking],
     :score => record[:score],
     :total_ranking => record[:total_ranking],
     :daily_ranking => record[:daily_ranking],}
  }
end
