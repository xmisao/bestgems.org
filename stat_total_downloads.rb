require 'sequel'
require 'date'
require_relative 'stat.rb'
DB = Sequel.sqlite('DB', :timeout => 60000)
total = DB[:total]
statistics = DB[:statistics]

date = ARGV[0] || (Date::today - 1).to_s

total_downloads = total.where(:date => date).sum(:downloads)

row = {:type => STAT_TOTAL_DOWNLOADS, :date => date, :value => total_downloads}

statistics.insert(row)
