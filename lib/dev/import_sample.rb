class ImportSample
  def execute
    raise "RDB is not empty." unless Gems.count == 0
    raise "LevelDB is not empty." unless Trend.empty?

    logger = Logger.new(STDOUT)

    num_of_gem = SampleGems::NAMES.count
    num_of_day = 30

    logger.info("Starting (gems: #{num_of_gem}, days: #{num_of_day})")

    gems = SampleGems::NAMES.map do |name|
      {
        name: name,
        version: Faker::App.version,
        summary: Faker::Quote.matz,
        last_downloads: rand_int,
      }
    end

    ((Date.today - num_of_day)..Date.today).each { |date|
      log_with("generate data for #{date}") do
        log_with("generate scraped_data") do
          scraped_data_list = gems.map { |gem|
            gem[:last_downloads] += rand_int
            {name: gem[:name], version: gem[:version], summary: gem[:summary], downloads: gem[:last_downloads], date: date}
          }

          ScrapedData.multi_insert scraped_data_list
        end

        execute_batch("../batch/update_gems.rb") do
          GemsUpdater.execute(date)
        end

        execute_batch("../batch/update_total_downloads.rb") do
          TotalDownloadsUpdater.execute(date)
        end

        execute_batch("../batch/update_daily_downloads.rb") do
          DailyDownloadsUpdater.execute(date)
        end

        execute_batch("../batch/update_total_ranking.rb") do
          TotalRankingUpdater.execute(date)
        end

        execute_batch("../batch/update_daily_ranking.rb") do
          DailyRankingUpdater.execute(date)
        end

        execute_batch("../batch/update_featured_score.rb") do
          FeaturedScoreUpdater.execute(date)
        end

        execute_batch("../batch/update_featured_ranking.rb") do
          FeaturedRankingUpdater.execute(date)
        end

        execute_batch("../batch/update_statistics_num_of_gems.rb") do
          StatisticsNumOfGemsUpdater.execute(date)
        end

        execute_batch("../batch/update_statistics_total_downloads.rb") do
          StatisticsTotalDownloadsUpdater.execute(date)
        end

        execute_batch("../batch/update_statistics_daily_downloads.rb") do
          StatisticsDailyDownloadsUpdater.execute(date)
        end

        execute_batch("../batch/update_trends.rb") do
          TrendUpdater.execute(date)
        end

        execute_batch("../batch/update_gems_latest_columns.rb") do
          GemsLatestColumnsUpdater.execute(date)
        end

        execute_batch("../batch/update_daily_summary.rb") do
          DailySummaryUpdater.execute(date)
        end

        execute_batch("../batch/update_master.rb") do
          MasterUpdater.execute(date)
        end
      end
    }

    logger.info("Completed!")
  end

  def logger
    @logger ||= Logger.new(STDOUT)
  end

  def rand_int(n = 2 ** 16)
    rand(n)
  end

  def log_with(msg)
    logger.info("Begin #{msg}")
    yield
    logger.info("End #{msg}")
  rescue => e
    logger.error("Failed! #{msg}")
    logger.error(e)
    raise
  end

  def execute_batch(path)
    log_with(path) do
      # NOTE Require batch script
      require_relative path

      yield
    end
  end
end
