require "sequel"

DB = Sequel.sqlite("db/master.sqlite3", :timeout => 60000)
total = DB[:total]
daily = DB[:daily]
master = DB[:master]
