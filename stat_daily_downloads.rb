require 'sequel'
require 'date'
require_relative 'stat.rb'
DB = Sequel.sqlite('DB', :timeout => 60000)
daily = DB[:daily]
statistics = DB[:statistics]

date = ARGV[0] || (Date::today - 1).to_s

daily_downloads = daily.where(:date => date).sum(:downloads)

row = {:type => STAT_DAILY_DOWNLOADS, :date => date, :value => daily_downloads}

statistics.insert(row)
