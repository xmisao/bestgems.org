#!/bin/bash

ruby lib/batch/scraping_all_gems.rb
ruby lib/batch/update_gems.rb
ruby lib/batch/update_total_downloads.rb
ruby lib/batch/update_daily_downloads.rb
ruby lib/batch/update_total_ranking.rb
ruby lib/batch/update_daily_ranking.rb
ruby lib/batch/update_featured_score.rb
ruby lib/batch/update_featured_ranking.rb
ruby lib/batch/update_statistics_num_of_gems.rb
ruby lib/batch/update_statistics_total_downloads.rb
ruby lib/batch/update_statistics_daily_downloads.rb
ruby lib/batch/update_trends.rb
ruby lib/batch/update_gems_latest_columns.rb
ruby lib/batch/update_master.rb
