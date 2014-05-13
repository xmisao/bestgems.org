require 'sequel'
require 'date'
require_relative 'stat.rb'
DB = Sequel.sqlite('DB', :timeout => 60000)
total = DB[:total]
statistics = DB[:statistics]

date = ARGV[0] || (Date::today - 1).to_s

num_of_gems = total.where(:date => date).count

row = {:type => STAT_NUM_OF_GEMS, :date => date, :value => num_of_gems}

statistics.insert(row)
