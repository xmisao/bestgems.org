class TrendDataSet
  def initialize(td_list)
    @sorted_td_list = td_list.sort_by { |td| td.date }
  end

  # For Web
  def downloads_trends
    @sorted_td_list.map { |td|
      {date: td.date, total_downloads: td.total_downloads, daily_downloads: td.daily_downloads}
    }
  end

  def ranking_trends
    @sorted_td_list.map { |td|
      {date: td.date, total_ranking: td.total_ranking, daily_ranking: td.daily_ranking}
    }
  end

  # For API
  def total_downloads
    @sorted_td_list.map { |td|
      {date: td.date, total_downloads: td.total_downloads}
    }
  end

  def daily_downloads
    @sorted_td_list.map { |td|
      {date: td.date, daily_downloads: td.daily_downloads}
    }
  end

  def total_ranking
    @sorted_td_list.map { |td|
      {date: td.date, total_ranking: td.total_ranking}
    }
  end

  def daily_ranking
    @sorted_td_list.map { |td|
      {date: td.date, daily_ranking: td.daily_ranking}
    }
  end
end
