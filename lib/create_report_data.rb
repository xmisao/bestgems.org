require 'sequel'
require 'date'
DB = Sequel.sqlite('db/master.sqlite3', :timeout => 60000)
total = DB[:total]
report_data = DB[:report_data]

limit = 100000
report_id = ARGV[0].to_i
term_start = Date.parse(ARGV[1])
term_end = Date.parse(ARGV[2])

gems = []

map = {}
total.where(:date => term_start).each{|row|
  map[row[:name]] = row
}

total.where(:date => term_end).order(Sequel.asc(:rank)).limit(limit).each{|term_end_row|
  name = term_end_row[:name]
  term_start_row = map[term_end_row[:name]]
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
  gems << {:name => term_end_row[:name], :summary => term_end_row[:summary], :downloads => downloads, :term_start_rank => term_start_rank, :term_end_rank => term_end_row[:rank], :rank_diff => rank_diff, :report_id => report_id}
}

gems.sort!{|g0, g1|
  g1[:downloads] - g0[:downloads]
}

prev_downloads = nil
prev_rank = nil
gems.each_with_index{|gem, i|
  if prev_downloads != gem[:downloads]
    gem[:rank] = i + 1
    prev_rank = gem[:rank]
    prev_downloads = gem[:downloads]
  else
    gem[:rank] = prev_rank
  end
}

DB.transaction do
  gems.each{|gem|
    report_data.insert gem
  }
end
