require 'sinatra'
require 'sequel'
require 'cgi'
require_relative 'pager'
require_relative 'stat'
require_relative 'database'

total = DB[:total]
daily = DB[:daily]
featured = DB[:featured]
master = DB[:master]
statistics = DB[:statistics]
reports = DB[:reports]
report_data = DB[:report_data]

def comma(i)
  if i
    i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\1,').reverse
  else
    "-"
  end
end

def n2n(v)
  v != nil ? v : 'null'
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

def link(name)
  "<a href='/gems/#{name}'>#{name}</a>"
end

def is_int?(str)
  str ? str.match(/^\d+$/) : true
end

configure do
  mime_type :json, 'application/json'
end

get '/' do
  date = master.first[:date]

  @title = "BestGems -- Ruby Gems Download Ranking"
  date = Master.first[:date]
  @total_gems = Ranking.total(date, 10) # total.where(:date => date).reverse_order(:downloads).limit(10)
  @daily_gems = Ranking.daily(date, 10) # daily.where(:date => date).reverse_order(:downloads).limit(10)
  @featured_gems = Ranking.featured(date, 10) # featured.where(:date => date).order(:rank).limit(10)
  @reports = reports.reverse_order(:id).limit(5)

  erb :top
end

get '/total' do
  redirect '/total' unless is_int?(params[:page])

  @title = 'Total Download Ranking -- Best Gems'
  @ranking_name = 'Total Donwload Ranking'
  @ranking_description = 'Most downloads over all time'

  @chart_title = 'Downloads'

  date = master.first[:date]
  per_page = 20
  page = params[:page] ? params[:page].to_i - 1 : 0

  @gems = Ranking.total(date, per_page, per_page * page) 

  @path = '/total'
  @opts = params
  @range = (1..(Ranking.total_count(date) / per_page.to_f).ceil)
  @page = page + 1

  @type = :total

  @start = per_page * page + 1
  @end = per_page * page + @gems.count
  @count = Ranking.total_count(date)

  erb :ranking
end

get '/daily' do
  redirect '/daily' unless is_int?(params[:page])

  @title = 'Daily Download Ranking -- Best Gems'
  @ranking_name = 'Daily Donwload Ranking'
  @ranking_description = 'Most downloads last day.'

  @chart_title = 'Downloads '

  date = master.first[:date]
  per_page = 20
  page = params[:page] ? params[:page].to_i - 1: 0

  @gems = Ranking.daily(date, per_page, per_page * page)

  @path = '/daily'
  @opts = params
  @range = (1..(Ranking.daily_count(date) / per_page.to_f).ceil)
  @page = page + 1

  @type = :daily

  @start = per_page * page + 1
  @end = per_page * page + @gems.count
  @count = Ranking.daily_count(date)

  erb :ranking
end

get '/featured' do
  redirect '/featured' unless is_int?(params[:page])

  @title = 'Featured Gems Ranking -- Best Gems'
  @ranking_name = 'Featured Gems Ranking'
  @ranking_description = 'Featured gems which are based on difference between daily rank and total rank.'

  @chart_title = 'Difference between daily rank and total rank'

  date = master.first[:date]
  per_page = 20
  page = params[:page] ? params[:page].to_i - 1: 0

  @gems = Ranking.featured(date, per_page, per_page * page)

  @path = '/featured'
  @opts = params
  @range = (1..(Ranking.featured_count(date) / per_page.to_f).ceil)
  @page = page + 1

  @type = :featured

  @start = per_page * page + 1
  @end = per_page * page + @gems.count
  @count = Ranking.featured_count(date)

  erb :featured
end

get '/stat/gems' do
  @title = "Number of All Gems -- BestGems"
  @graph = []
  statistics.where(:type => STAT_NUM_OF_GEMS).order(:date).each{|row|
    @graph << {:date => row[:date], :num_of_gems => row[:value]}
  }
  @name = 'Number of All Gems'
  @summary = "There are #{@graph[-1][:num_of_gems]} gems today. And over 50 gems are born every day."

  erb :stat_gems
end

def join_total_daily_download_of_all_gems(total_graph, daily_graph)
  graph = []

  total_map = {}

  total_graph.each{|row|
    total_map[row[:date]] = row[:value]
  }

  daily_graph.each{|row|
    graph << {:date => row[:date], :daily_downloads => row[:value], :total_downloads => total_map[row[:date]]}
  }

  graph
end

get '/stat/download' do
  @title = "Download Trends of All Gems -- BestGems"
  total_graph = statistics.where(:type => STAT_TOTAL_DOWNLOADS).order(:date)
  daily_graph = statistics.where(:type => STAT_DAILY_DOWNLOADS).order(:date)
  @graph = join_total_daily_download_of_all_gems(total_graph, daily_graph)
  @name = 'Download Trends of All Gems'
  @summary = "Sum of download count of all gems."

  erb :stat_download
end

get '/reports/:url' do
  url = params[:url]
  redirect '/reports/' + url unless is_int?(params[:page])

  report = reports.where(:url => url).first
  report_id = report[:id]

  per_page = 20
  page = params[:page] ? params[:page].to_i - 1: 0

  results = report_data.where(:report_id => report_id).reverse_order(:downloads)
  gems = results.limit(per_page, per_page * page)

  @title = "#{report[:name]} Report -- Best Gems"
  @ranking_name = report[:name]
  @ranking_description = report[:summary]

  @chart_title = 'Downloads'

  @gems = gems
  @rank = page * per_page

  @path = '/reports/' + url
  opts = params.clone
  opts.delete("splat")
  opts.delete("captures")
  opts.delete("url")
  @opts = opts
  @range = (1..(report_data.where(:report_id => report_id).reverse_order(:downloads).count / per_page))
  @page = page + 1

  @type = :reports

  @start = per_page * page + 1
  @end = per_page * page + @gems.count
  @count = results.count

  erb :report
end

get '/gems/:gems' do
  redirect '/' unless params[:gems]

  gem = Gems.where(:name => params[:gems]).first
  p gem
  redirect '/' unless gem

  date = Master.first[:date]
  info = gem.info(date)

  @title = "#{info[:name]} -- BestGems"

  @downloads_trends = gem.downloads_trends
  @ranking_trends = gem.ranking_trends

  @total_count = Ranking.total_count(date)
  @daily_count = Ranking.daily_count(date)

  @gem_name = info[:name]
  @gem_summary = info[:summary]
  @total_downloads = info[:total_downloads]
  @total_rank = info[:total_ranking]
  @daily_downloads = info[:daily_downloads]
  @daily_rank = info[:daily_ranking]

  erb :gems
end

get '/search' do
  redirect '/' unless is_int?(params[:page])
  redirect '/' unless params[:q]
  redirect '/' if params[:q].match(/\A\s*\z/)

  date = master.first[:date]
  per_page = 20
  page = params[:page] ? params[:page].to_i - 1: 0

  @title = "Search -- BestGems"

  query = params[:q]
  results = Gems.search(date, query)
  @gems = results.limit(per_page, per_page * page)

  @q = CGI.escapeHTML(query)

  @path = '/search'
  @opts = params
  @range = (1..(results.count / per_page.to_f).ceil)
  @page = page + 1

  @start = per_page * page + 1
  @end = per_page * page + @gems.count
  @count = results.count

  erb :search
end

get '/about' do
  @title = "About This Site -- BestGems"
  @type = :about
  erb :about
end

get '/api/v1/gems/:name/total_downloads.json' do
  content_type :json

  gem = Gems.where(:name => params[:name]).first
  break 404 unless gem

  JSON.dump(gem.total_downloads_trends
               .reverse
               .map{|record| {:date => record[:date].to_s, :total_downloads => record[:downloads]}})
end

get '/api/v1/gems/:name/daily_downloads.json' do
  content_type :json

  gem = Gems.where(:name => params[:name]).first
  break 404 unless gem

  JSON.dump(gem.daily_downloads_trends
               .reverse
               .map{|record| {:date => record[:date].to_s, :daily_downloads => record[:downloads]}})
end

get '/api/v1/gems/:name/total_ranking.json' do
  content_type :json

  gem = Gems.where(:name => params[:name]).first
  break 404 unless gem

  JSON.dump(gem.total_ranking_trends
               .reverse
               .map{|record| {:date => record[:date].to_s, :total_ranking => record[:ranking]}})
end

get '/api/v1/gems/:name/daily_ranking.json' do
  content_type :json

  gem = Gems.where(:name => params[:name]).first
  break 404 unless gem

  JSON.dump(gem.daily_ranking_trends
               .reverse
               .map{|record| {:date => record[:date].to_s, :daily_ranking => record[:ranking]}})
end
