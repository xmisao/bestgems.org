require 'date'
require_relative '../database'

class StatisticsNumOfGemsUpdater
  def self.execute(date)
    batch_trace('StatisticsNumOfGemsUpdater', 'execute', [date]){
      num_of_gems = Value.where(:type => Value::Type::TOTAL_DOWNLOADS,
                                :date => date).count

      row = {:type => Statistics::Type::NUM_OF_GEMS,
             :date => date,
             :value => num_of_gems}

      Statistics.insert(row) # TODO: Idempotence
    }
  end
end

if $0 == __FILE__
  date = ARGV[0] || Date.today - 1
  StatisticsNumOfGemsUpdater.execute(date)
end
