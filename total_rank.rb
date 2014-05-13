require 'sequel'
require 'date'

DB = Sequel.sqlite('DB', :timeout => 60000)
total = DB[:total]
daily = DB[:daily]

date = Date::today - 1

rank = 1
last_rank = 1
last_downloads = 2 ** 63
DB.transaction do
	total.where(:date => date).reverse_order(:downloads).each{|row|
		if row[:downloads] < last_downloads
			last_rank = rank
			last_downloads = row[:downloads]
		end
		total.where(:date => date, :name => row[:name]).update(:rank => last_rank)
		STDERR.puts last_rank.to_s + ' ' + row[:name]
		
		rank += 1
	}
end
