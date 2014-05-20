require 'sinatra'
require 'sequel'
require 'cgi'
require_relative 'pager'
require_relative 'stat'

DB = Sequel.sqlite('db/master.sqlite3', :timeout => 60000)
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

get '/' do
  date = master.first[:date]

  @title = "BestGems -- Ruby Gems Download Ranking"
  @total_gems = total.where(:date => date).reverse_order(:downloads).limit(10)
  @daily_gems = daily.where(:date => date).reverse_order(:downloads).limit(10)
  @featured_gems = featured.where(:date => date).order(:rank).limit(10)
  @reports = reports.reverse_order(:id).limit(5)

  erb :top
end

get '/total' do
  redirect '/total' unless is_int?(params[:page])

  date = master.first[:date]

  per_page = 20
  page = params[:page] ? params[:page].to_i - 1: 0

  results = total.where(:date => date).reverse_order(:downloads)
  gems = results.limit(per_page, per_page * page)

  @title = 'Total Download Ranking -- Best Gems'
  @ranking_name = 'Total Donwload Ranking'
  @ranking_description = 'Most downloads over all time'

  @chart_title = 'Downloads'

  @gems = gems
  @rank = page * per_page

  @path = '/total'
  @opts = params
  @range = (1..(total.where(:date => date).reverse_order(:downloads).count / per_page))
  @page = page + 1

  @type = :total

  @start = per_page * page + 1
  @end = per_page * page + @gems.count
  @count = results.count

  erb :ranking
end

get '/daily' do
  redirect '/daily' unless is_int?(params[:page])

  date = master.first[:date]

  per_page = 20
  page = params[:page] ? params[:page].to_i - 1: 0

  results = daily.where(:date => date).reverse_order(:downloads)
  gems = results.limit(per_page, per_page * page)

  @title = 'Daily Download Ranking -- Best Gems'
  @ranking_name = 'Daily Donwload Ranking'
  @ranking_description = 'Most downloads last day.'

  @chart_title = 'Downloads '

  @gems = gems
  @rank = page * per_page

  @path = '/daily'
  @opts = params
  @range = (1..(daily.where(:date => date).reverse_order(:downloads).count / per_page))
  @page = page + 1

  @type = :daily

  @start = per_page * page + 1
  @end = per_page * page + @gems.count
  @count = results.count

  erb :ranking
end

get '/featured' do
  redirect '/featured' unless is_int?(params[:page])

  date = master.first[:date]

  per_page = 20
  page = params[:page] ? params[:page].to_i - 1: 0

  results = featured.where(:date => date).order(:rank)
  gems = results.limit(per_page, per_page * page)

  @title = 'Featured Gems Ranking -- Best Gems'
  @ranking_name = 'Featured Gems Ranking'
  @ranking_description = 'Featured gems which are based on difference between daily rank and total rank.'

  @chart_title = 'Difference between daily rank and total rank'

  @gems = gems
  @rank = page * per_page

  @path = '/featured'
  @opts = params
  @range = (1..(featured.where(:date => date).order(:rank).count / per_page))
  @page = page + 1

  @type = :featured

  @start = per_page * page + 1
  @end = per_page * page + @gems.count
  @count = results.count

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

  @title = "#{report[:name]} Repot -- Best Gems"
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

def join_total_daily_download_graph(total_graph, daily_graph)
  graph = []

  total_map = {}

  total_graph.each{|row|
    total_map[row[:date]] = row[:downloads]
  }

  daily_graph.each{|row|
    graph << {:date => row[:date], :daily_downloads => row[:downloads], :total_downloads => total_map[row[:date]]}
  }

  graph
end

def join_total_daily_rank_graph(total_graph, daily_graph)
  graph = []

  total_map = {}

  total_graph.each{|row|
    total_map[row[:date]] = row[:rank]
  }

  daily_graph.each{|row|
    graph << {:date => row[:date], :daily_rank => row[:rank], :total_rank => total_map[row[:date]]}
  }

  graph
end

get '/gems/:gems' do
  redirect '/' unless params[:gems]

  total_date = master.first[:date]
  daily_date = master.first[:date]

  name = params[:gems]

  redirect '/' unless total.where(:name => name, :date => total_date).first

  @title = "#{name} -- BestGems"

  total_download_graph = total.where(:name => name)
  daily_download_graph = daily.where(:name => name)
  @download_graph = join_total_daily_download_graph(total_download_graph, daily_download_graph)

  total_rank_graph = total.where(:name => name)
  daily_rank_graph = daily.where(:name => name)
  @rank_graph = join_total_daily_rank_graph(total_rank_graph, daily_rank_graph)

  @total_count = total.where(:date => total_date).count
  @daily_count = daily.where(:date => daily_date).count

  total_row = total.where(:name => name, :date => total_date).first
  daily_row = daily.where(:name => name, :date => daily_date).first || {:downloads => "-", :rank => "-"}

  @gem_name = total_row[:name]
  @gem_summary = total_row[:summary]
  @total_downloads = total_row[:downloads]
  @total_rank = total_row[:rank]

  @daily_downloads = daily_row[:downloads]
  @daily_rank = daily_row[:rank]

  erb :gems
end

get '/search' do
  redirect '/search' unless is_int?(params[:page])
  redirect '/search' unless params[:q]

  date = master.first[:date]
  per_page = 20
  page = params[:page] ? params[:page].to_i - 1: 0

  @title = "Search -- BestGems"

  qp = params[:q] || ""
  or_part = nil
  qp.split(/\s/)[0..4].each{|q|
    part = Sequel.like(:name, "%#{q}%") | Sequel.like(:summary, "%#{q}%")
    if or_part
      or_part &= part
    else
      or_part = part
    end
  }
  results = total.where(:date => date).where(or_part).reverse_order(:downloads)
  @gems = results.limit(per_page, per_page * page)

  @q = CGI.escapeHTML(qp)

  @path = '/search'
  @opts = params
  @range = (1..(results.count / per_page))
  @page = page + 1

  @start = per_page * page + 1
  @end = per_page * page + @gems.count
  @count = results.count

  erb :search
end

get '/about' do
  @title = "About This Site -- BestGems"
  erb :about
end
