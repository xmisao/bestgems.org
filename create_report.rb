require 'sequel'
DB = Sequel.sqlite('DB', :timeout => 60000)
reports = DB[:reports]

p reports.insert({:name => ARGV[0], :summary => ARGV[1], :url => ARGV[2]})
