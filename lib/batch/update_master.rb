require "date"
require_relative "../database"

class MasterUpdater
  def self.execute(date)
    batch_trace("MasterUpdater", "execute", [date]) {
      case Master.count
      when 0
        Master.insert(:date => date)
      when 1
        Master.dataset.update(:date => date)
      else
        raise "Database inconsistency."
      end
    }
  end
end

if $0 == __FILE__
  date = ARGV[0] || Date.today - 1
  MasterUpdater.execute(date)
end
