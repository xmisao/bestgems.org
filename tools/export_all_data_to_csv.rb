require "open-uri"
require "json"
require "csv"
require_relative "./bestgems_api"

class BestGemsExporter
  GEM_ATTRIBUTES = %w(
    gem_id
    name
    summary
    version
    latest_total_downloads
    latest_total_ranking
    latest_daily_downloads
    latest_daily_ranking
    latest_update_date
  )
  GEM_HEADERS = GEM_ATTRIBUTES.dup

  TREND_DATA_ATTRIBUTES = %w(
    date
    total_downloads
    total_ranking
    daily_downloads
    daily_ranking
  )
  TREND_DATA_HEADERS = ["gem_id"] + TREND_DATA_ATTRIBUTES

  def export
    api = BestGemsApi.new

    page = 1
    while (gems = api.gems(page)).count > 0
      gems.each do |gem|
        puts_gem(gem)

        gem_id = gem["gem_id"]
        gem_name = gem["name"]

        trends = api.trends(gem_name)
        puts_trends(gem_id, trends)

        flush
      end

      page += 1
    end
  ensure
    gems_csv.close
    trends_csv.close
  end

  def puts_gem(gem)
    row = GEM_ATTRIBUTES.map { |attr| gem[attr] }

    gems_csv << row
  end

  def gems_csv
    @gems_csv ||= CSV.open("gems.csv", "w", headers: GEM_HEADERS, write_headers: true)
  end

  def puts_trends(gem_id, trends)
    trends.each do |trend_data|
      trends_csv << [gem_id] + TREND_DATA_ATTRIBUTES.map { |attr| trend_data[attr] }
    end
  end

  def trends_csv
    @trends_csv ||= CSV.open("trends.csv", "w", headers: TREND_DATA_HEADERS, write_headers: true)
  end

  def flush
    @gems_csv.flush
    @trends_csv.flush
  end
end

BestGemsExporter.new.export
