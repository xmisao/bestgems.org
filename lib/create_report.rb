require "sequel"
DB = Sequel.sqlite("db/master.sqlite3", :timeout => 60000)
reports = DB[:reports]

p reports.insert({:name => ARGV[0], :summary => ARGV[1], :url => ARGV[2]})
