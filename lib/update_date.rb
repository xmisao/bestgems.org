require 'sequel'
require 'date'

DB = Sequel.sqlite('db/master.sqlite3', :timeout => 60000)
total = DB[:total]
daily = DB[:daily]
master = DB[:master]

master.update(:date => Date::today - 1)

# p row = master.first
# row.update(:date => Date::today - 1)
