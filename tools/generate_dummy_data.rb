require_relative '../lib/database'
require 'logger'

$logger = Logger.new(STDOUT)

case ENV['RACK_ENV']
when 'development'
when 'production'
else
  puts "You should set value 'development'(to use SQLite3) or 'production'(to use PostgreSQL) to RACK_ENV environment variable."
  exit 1
end

num_of_gem = 100
num_of_day = 30

num_of_gem = ARGV[0].to_i if ARGV[0]
num_of_day = ARGV[1].to_i if ARGV[1]

CHARS = [('a'..'z'), ('A'..'Z'), ('0'..'9')].map { |i| i.to_a }.flatten

def rand_str(n = 64)
  (0...(rand(n) + 1)).map { CHARS[rand(CHARS.length)] }.join 
end

def rand_sentence(n = 10)
  (0...(rand(n)) + 1).map { rand_str(10) }.join(' ')
end

def rand_int(n = 2 ** 32)
  rand(n)
end

raise 'RDB is not empty.' unless Master.first == nil
raise 'LevelDB is not empty.' unless Trend.empty?

begin
  num_of_gem.times{|gem_id|
    $logger.info("Generating gem #{gem_id} of #{num_of_gem}")

    Gems.insert(id: gem_id,
                name: rand_str,
                version: "#{rand_int(10)}.#{rand_int(10)}",
                summary: rand_sentence)

    gem = Gems[gem_id]
    td_list = []

    ((Date.today - num_of_day)..Date.today).each{|date|
      [Value::Type::TOTAL_DOWNLOADS, Value::Type::DAILY_DOWNLOADS].each{|type|
        Value.insert(:type => type,
                     :gem_id => gem_id,
                     :date => date,
                     :value => rand_int)
      }

      [Ranking::Type::TOTAL_RANKING, Ranking::Type::DAILY_RANKING].each{|type|
        Ranking.insert(:type => type,
                       :gem_id => gem_id,
                       :date => date,
                       :ranking => rand_int)
      }

      td_list << gem.get_trend_data_from_rdb(date)
    }

    gem.put_trend_data(*td_list)
  }

  Master.insert(date: Date.today)
rescue => e
  $logger.error(e)

  raise
end
