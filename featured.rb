require 'sequel'
require 'date'
DB = Sequel.sqlite('DB', :timeout => 60000)
total = DB[:total]
daily = DB[:daily]
master = DB[:master]
featured = DB[:featured]

featured_gems = []

date = ARGV[0] || (Date::today - 1).to_s
limit = 1000

daily.where(:date => date).order(Sequel.asc(:rank)).limit(limit).each{|daily_row|
	total_row = total.where(:name => daily_row[:name], :date => date).first
	rank_diff = total_row[:rank] - daily_row[:rank]
	featured_gems << {:name => daily_row[:name], :summary => daily_row[:summary], :date => daily_row[:date], :daily_rank => daily_row[:rank], :total_rank  => total_row[:rank], :rank_diff => rank_diff}
}

featured_gems.sort!{|g0, g1|
	g1[:rank_diff] - g0[:rank_diff]
}

featured_gems.each_with_index{|gem, i|
	gem[:rank] = i + 1
}

featured_gems.each{|gem|
	DB.transaction{
		featured.insert(gem)
	}
}
