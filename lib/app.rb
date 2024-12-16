require_relative "database"
require_relative "pager"
require_relative "stat"

helpers WebUtils

total = DB[:total]
daily = DB[:daily]
featured = DB[:featured]
master = DB[:master]
statistics = DB[:statistics]
reports = DB[:reports]
report_data = DB[:report_data]

SITEMAP_SLICE = 40000
SITE_URL = "http://bestgems.org"

def ranking_labels(ranking_trends)
  ranking_trends.map { |t| t[:date] }.to_json
end

def ranking_total_data(ranking_trends)
  ranking_trends.map { |t| n2n(t[:total_ranking]) }.to_json
end

def ranking_daily_data(ranking_trends)
  ranking_trends.map { |t| n2n(t[:daily_ranking]) }.to_json
end

def downloads_labels(downloads_trends)
  downloads_trends.map { |t| t[:date] }.to_json
end

def downloads_total_data(downloads_trends)
  downloads_trends.map { |t| n2n(t[:total_downloads]) }.to_json
end

def downloads_daily_data(downloads_trends)
  downloads_trends.map { |t| n2n(t[:daily_downloads]) }.to_json
end

def trends_label(graph)
  graph.map { |t| t[:date] }.to_json
end

def num_of_gems_data(graph)
  graph.map { |t| t[:num_of_gems] }.to_json
end

def num_of_versions_labels(num_of_versions_trends)
  num_of_versions_trends.map { |t| t[:date] }.to_json
end

def num_of_versions(num_of_versions_trends)
  num_of_versions_trends.map { |t| n2n(t[:num]) }.to_json
end

def popular_versions_labels(popular_versions)
  popular_versions.map { |t| t[:version] }.to_json
end

def popular_versions_data(popular_versions)
  popular_versions.map { |t| n2n(t[:downloads]) }.to_json
end

def padding_versions(popular_versions, num)
  popular_versions + (num - popular_versions.length).times.map { {version: "-", downloads: 0} }
end

def comma(i)
  if i
    i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\1,').reverse
  else
    "-"
  end
end

def n2n(v)
  v != nil ? v : "null"
end

def comma_pm(i)
  if i
    pre = "+/-"
    if i > 0
      pre = "+"
    elsif i < 0
      pre = ""
    end
    pre + i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\1,').reverse
  else
    "-"
  end
end

def link_by_gem_name(name)
  "<a href='/gems/#{name}'>#{name}</a>"
end

def is_int?(str)
  str ? str.match(/^\d+$/) : true
end

configure do
  mime_type :json, "application/json"
end

get "/" do
  @title = "BestGems -- Ruby Gems Download Ranking"
  date = Master.first[:date]
  @total_gems = Ranking.total(date, 10)
  @daily_gems = Ranking.daily(date, 10)
  @featured_gems = Ranking.featured(date, 10)
  @reports = reports.reverse_order(:id).limit(5)

  erb :top
end

get "/total" do
  redirect "/total" unless is_int?(params[:page])

  @title = "Total Downloads Ranking -- BestGems.org"
  @ranking_name = "Total Downloads Ranking"
  @ranking_description = "Most downloads over all time"

  @chart_title = "Downloads"

  date = master.first[:date]
  per_page = 20
  page = params[:page] ? params[:page].to_i - 1 : 0

  @gems = Ranking.total(date, per_page, per_page * page)

  @path = "/total"
  @opts = params
  @range = (1..(Ranking.total_count(date) / per_page.to_f).ceil)
  @page = page + 1

  @type = :total

  @start = per_page * page + 1
  @end = per_page * page + @gems.count
  @count = Ranking.total_count(date)

  erb :ranking
end

get "/daily" do
  redirect "/daily" unless is_int?(params[:page])

  @title = "Daily Downloads Ranking -- BestGems.org"
  @ranking_name = "Daily Downloads Ranking"
  @ranking_description = "Most downloads last day."

  @chart_title = "Downloads "

  date = master.first[:date]
  per_page = 20
  page = params[:page] ? params[:page].to_i - 1 : 0

  @gems = Ranking.daily(date, per_page, per_page * page)

  @path = "/daily"
  @opts = params
  @range = (1..(Ranking.daily_count(date) / per_page.to_f).ceil)
  @page = page + 1

  @type = :daily

  @start = per_page * page + 1
  @end = per_page * page + @gems.count
  @count = Ranking.daily_count(date)

  erb :ranking
end

get "/featured" do
  redirect "/featured" unless is_int?(params[:page])

  @title = "Featured Gems Ranking -- BestGems.org"
  @ranking_name = "Featured Gems Ranking"
  @ranking_description = "Featured gems which are based on difference between daily rank and total rank."

  @chart_title = "Difference between daily rank and total rank"

  date = master.first[:date]
  per_page = 20
  page = params[:page] ? params[:page].to_i - 1 : 0

  @gems = Ranking.featured(date, per_page, per_page * page)

  @path = "/featured"
  @opts = params
  @range = (1..(Ranking.featured_count(date) / per_page.to_f).ceil)
  @page = page + 1

  @type = :featured

  @start = per_page * page + 1
  @end = per_page * page + @gems.count
  @count = Ranking.featured_count(date)

  erb :featured
end

get "/stat/gems" do
  @title = "Number of All Gems -- BestGems"
  @graph = []
  statistics.where(:type => STAT_NUM_OF_GEMS).order(:date).each { |row|
    @graph << {:date => row[:date], :num_of_gems => row[:value]}
  }
  @name = "Number of All Gems"
  @summary = "There are #{@graph[-1][:num_of_gems]} gems today. And over 50 gems are born every day."

  erb :stat_gems
end

def join_total_daily_download_of_all_gems(total_graph, daily_graph)
  graph = []

  total_map = {}

  total_graph.each { |row|
    total_map[row[:date]] = row[:value]
  }

  daily_graph.each { |row|
    graph << {:date => row[:date], :daily_downloads => row[:value], :total_downloads => total_map[row[:date]]}
  }

  graph
end

get "/stat/downloads" do
  @title = "Downloads Trends of All Gems -- BestGems"
  total_graph = statistics.where(:type => STAT_TOTAL_DOWNLOADS).order(:date)
  daily_graph = statistics.where(:type => STAT_DAILY_DOWNLOADS).order(:date)
  @graph = join_total_daily_download_of_all_gems(total_graph, daily_graph)
  @name = "Downloads Trends of All Gems"
  @summary = "Sum of downloads of all gems."

  erb :stat_download
end

get "/gems/:gems" do
  gem_name = params[:gems]

  redirect "/" unless gem_name

  gem = Gems.fetch_gem_by_name(gem_name)
  redirect "/" unless gem

  unless gem.enable
    response.status = 403
    break erb :disabled
  end

  date = Master.first[:date]
  latest = gem.latest_trend(date)

  @title = "#{gem[:name]} -- BestGems"

  trend = TrendDataSet.new(gem.get_trend_data)
  @downloads_trends = trend.downloads_trends
  @ranking_trends = trend.ranking_trends

  @total_count = Ranking.total_count(date)
  @daily_count = Ranking.daily_count(date)

  @gem_name = gem.name
  @gem_summary = gem.description
  @total_downloads = latest[:total_downloads]
  @total_rank = latest[:total_ranking]
  @daily_downloads = latest[:daily_downloads]
  @daily_rank = latest[:daily_ranking]
  @depends_on = gem.depends_on_gems
  @depended_by = gem.depended_by_gems
  @categories = gem.categories
  @owners = gem.owners
  @github_url = gem.github_url

  from_date = @downloads_trends.first&.fetch(:date)
  to_date = @downloads_trends.last&.fetch(:date)

  @num_of_versions_trends = gem.num_of_versions_trends(from_date, to_date)

  @popular_versions_by_major_version = padding_versions(gem.popular_versions_by_major_version, 10)
  @popular_versions_by_major_minor_version = padding_versions(gem.popular_versions_by_major_minor_version, 10)

  erb :gems
end

get "/gems/:gems/categories" do
  gem_name = params[:gems]

  redirect "/" unless gem_name

  @gem = Gems.fetch_gem_by_name(gem_name)

  redirect "/" unless @gem

  @gem_categories = @gem.categories.to_a

  @token = Token.create.string

  @action = "/gems/#{@gem.name}/categories"

  @categories = Category.to_a

  @title = "Edit #{@gem.name}'s Categories -- BestGems.org"

  erb :gem_categories
end

post "/gems/:gems/categories" do
  gem_name = params[:gems]

  redirect "/" unless gem_name

  gem = Gems.fetch_gem_by_name(gem_name)

  next 404 unless gem

  category_ids = params["categories"] ? params["categories"].map(&:to_i) : []
  categories = Category.where(id: category_ids).to_a

  believe = params["believe"]
  token = Token.new(params["token"])

  CategoryChange.new(gem, categories, token, believe).execute

  redirect "/gems/#{gem.name}"
end

get "/search" do
  redirect "/" unless is_int?(params[:page])
  redirect "/" unless params[:q]
  redirect "/" if params[:q].match(/\A\s*\z/)

  date = master.first[:date]
  per_page = 20
  page = params[:page] ? params[:page].to_i - 1 : 0

  @title = "Search -- BestGems"

  query = params[:q]
  results = Gems.search(date, query)
  @gems = results.limit(per_page, per_page * page)

  @q = CGI.escapeHTML(query)

  @path = "/search"
  @opts = params
  @range = (1..(results.count / per_page.to_f).ceil)
  @page = page + 1

  @start = per_page * page + 1
  @end = per_page * page + @gems.count
  @count = results.count

  erb :search
end

get "/about" do
  @title = "About This Site -- BestGems"
  @type = :about
  erb :about
end

get "/categories" do
  @categories = Category.to_a

  @title = "Categories -- BestGems.org"

  erb :categories
end

get "/categories/:name" do
  name = Category.unescape(params[:name])

  @category = Category.fetch_by_name(name)

  break 404 unless @category

  @gems = @category.gems

  @title = "#{@category.name} Gems -- BestGems.org"

  erb :category
end

get "/category_change_histories" do
  @histories = GemCategoryChangeHistory.list

  erb :category_change_histories
end

get "/owners/:owner_id" do
  break 400 unless params[:owner_id].match(/\A\d{1,16}\Z/)

  owner_id = params[:owner_id].to_i

  break 404 unless owner_id > 0

  @owner = GemOwner.fetch_latest_by_owner_id(owner_id)

  break 404 unless @owner

  @gems = GemOwner.owned_gems(owner_id)

  @title = "#{@owner.handle_for_display.capitalize}'s Gems -- BestGems.org"

  erb :owner
end

get "/api/v1/gems/:name/total_downloads.json" do
  content_type :json

  gem = Gems.where(:name => params[:name]).first
  break 404 unless gem

  trend = TrendDataSet.new(gem.get_trend_data)

  JSON.dump(trend.total_downloads.reverse)
end

get "/api/v1/gems/:name/daily_downloads.json" do
  content_type :json

  gem = Gems.where(:name => params[:name]).first
  break 404 unless gem

  trend = TrendDataSet.new(gem.get_trend_data)

  JSON.dump(trend.daily_downloads.reverse)
end

get "/api/v1/gems/:name/total_ranking.json" do
  content_type :json

  gem = Gems.where(:name => params[:name]).first
  break 404 unless gem

  trend = TrendDataSet.new(gem.get_trend_data)

  JSON.dump(trend.total_ranking.reverse)
end

get "/api/v1/gems/:name/daily_ranking.json" do
  content_type :json

  gem = Gems.where(:name => params[:name]).first
  break 404 unless gem

  trend = TrendDataSet.new(gem.get_trend_data)

  JSON.dump(trend.daily_ranking.reverse)
end

get "/sitemap.xml" do
  @site_url = SITE_URL
  @gems_count = Gems.count
  @lastmod = Master.first.date.to_time.iso8601

  erb :sitemap_index, layout: false
end

get "/sitemaps/gems*.xml" do
  index = params["splat"][0].to_i

  @site_url = SITE_URL
  @gems = Gems.where(enable: true).order(:id).limit(SITEMAP_SLICE, index * SITEMAP_SLICE)

  erb :sitemap_gems, layout: false
end

get "/sitemap_general.xml" do
  @site_url = SITE_URL
  @gems_count = Gems.count
  @lastmod = Master.first.date.to_time.iso8601
  @categories = Category.all

  erb :sitemap_general, layout: false
end

# NOTE BestGems API v2 is under designing!

get "/api/v2/gems.json" do
  api_handler do
    Gems.fetch_gems_on_page(page).map(&:to_hash).to_json
  end
end

get "/api/v2/gems/:name/trends.json" do
  api_handler do
    gem = expect(Gems.fetch_gem_by_name(params[:name]))

    TrendDataSet.new(gem.get_trend_data).as_json.to_json
  end
end

put "/api/v2/gems/:name.json" do
  api_handler(require_authentication: true, succeed: 201) do
    name = json["name"]

    gem = Gems.fetch_gem_by_name(name) || Gems.new

    gem.update_by_json(json)

    gem.save(raise_on_failure: true)

    ""
  end
end

put "/api/v2/gems/:name/trends.json" do
  api_handler(require_authentication: true, succeed: 201) do
    tds = TrendDataSet.from_json(json)

    gem = expect(Gems.fetch_gem_by_name(params[:name]))

    Trend.put(gem.id, *tds.to_td_list)

    ""
  end
end

put "/api/v2/gems/:name/detail.json" do
  api_handler(require_authentication: true, succeed: 201) do
    gem = expect(Gems.fetch_gem_by_name(params[:name]))

    detail = Detail.fetch_by_gem_id(gem.id) || Detail.new(gem_id: gem.id)

    detail.update_by_json(json)

    detail.save(raise_on_failure: true)

    ""
  end
end

put "/api/v2/gems/:name/dependencies.json" do
  api_handler(require_authentication: true, succeed: 201) do
    gem = expect(Gems.fetch_gem_by_name(params[:name]))

    Dependency.replace_by_json(gem, json)

    ""
  end
end

put "/api/v2/gems/:name/versions.json" do
  api_handler(require_authentication: true, succeed: 201) do
    gem = expect(Gems.fetch_gem_by_name(params[:name]))

    GemVersion.replace_by_json(gem, json)

    ""
  end
end

put "/api/v2/gems/:name/owners.json" do
  api_handler(require_authentication: true, succeed: 201) do
    gem = expect(Gems.fetch_gem_by_name(params[:name]))

    GemOwner.replace_by_json(gem, json)

    ""
  end
end

get "/api/v2/days/:date/downloads.json" do
  api_handler do
    Statistics.day_as_json(params[:date]).to_json
  end
end

get "/api/v2/statistics/gems/count.json" do
  api_handler do
    Statistics.gems_count_as_json.to_json
  end
end

put "/api/v2/statistics/gems/count.json" do
  api_handler(require_authentication: true, succeed: 201) do
    Statistics.replace_gems_count_from_json(json)
  end
end

get "/api/v2/statistics/downloads/total.json" do
  api_handler do
    Statistics.total_downloads_as_json.to_json
  end
end

put "/api/v2/statistics/downloads/total.json" do
  api_handler(require_authentication: true, succeed: 201) do
    Statistics.replace_total_downloads_from_json(json)
  end
end

get "/api/v2/statistics/downloads/daily.json" do
  api_handler do
    Statistics.daily_downloads_as_json.to_json
  end
end

put "/api/v2/statistics/downloads/daily.json" do
  api_handler(require_authentication: true, succeed: 201) do
    Statistics.replace_daily_downloads_from_json(json)
  end
end
