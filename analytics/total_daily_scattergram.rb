require 'sequel'
require 'date'
DB = Sequel.sqlite('../DB', :timeout => 60000)
total = DB[:total]
daily = DB[:daily]
master = DB[:master]

date = ARGV[0] || (Date::today - 1).to_s
limit = 100000

daily.where(:date => date).order(Sequel.asc(:rank)).limit(limit).each{|daily_row|
	total_row = total.where(:name => daily_row[:name], :date => date).first
	puts [total_row[:rank], daily_row[:rank]].join(' ')
}
