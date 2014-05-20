require 'sequel'
require 'date'
DB = Sequel.sqlite('db/master.sqlite3', :timeout => 60000)
total = DB[:total]
daily = DB[:daily]
master = DB[:master]

limit = 100000
term_start = Date.parse('2013-06-27')
term_end = Date.parse('2013-12-31')

gems = []

total.where(:date => term_end).order(Sequel.asc(:rank)).limit(limit).each{|term_end_row|
  name = term_end_row[:name]
  term_start_row = total.where(:name => name, :date => term_start).first
  term_start_rank = nil
  downloads = nil
  if term_start_row
    rank_diff = term_start_row[:rank] - term_end_row[:rank]
    term_start_rank = term_start_row[:rank]
    downloads = term_end_row[:downloads] - term_start_row[:downloads]
  else
    rank_diff = nil
    downloads = term_end_row[:downloads]
  end
  gems << {:name => term_end_row[:name], :summary => term_end_row[:summary], :downloads => downloads, :term_start_rank => term_start_rank, :term_end_rank => term_end_row[:rank], :rank_diff => rank_diff, :report_id => '2013H2'}
}

gems.sort!{|g0, g1|
  g1[:downloads] - g0[:downloads]
}

gems.each_with_index{|gem, i|
  gem[:rank] = i + 1
}

gems.each{|gem|
  p gem
}
