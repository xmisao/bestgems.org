require_relative "../database"

class DeleteOldData
  DELETE_UNIT = 1_000_000

  def initialize(date)
    batch_trace("DeleteOldData", "initialize", [date]) {
      @date = date
    }
  end

  def to_date
    @date - 7
  end

  def execute()
    batch_trace("DeleteOldData", "execute", []) {
      delete_values
      delete_rankings
    }
  end

  def delete_values
    batch_trace("DeleteOldData", "delete_values") {
      deleted = Value.where(Sequel.lit("date < ?", to_date)).delete

      BatchLogger.info(type: :progress, target: :value, deleted: deleted)
    }
  end

  def delete_rankings
    batch_trace("DeleteOldData", "delete_rankings") {
      deleted = Ranking.where(Sequel.lit("date < ?", to_date)).delete

      BatchLogger.info(type: :progress, target: :ranking, deleted: deleted)
    }
  end
end

if $0 == __FILE__
  date ||= Date.parse(ARGV[0]) if ARGV[0]
  date ||= Date.today - 1
  DeleteOldData.new(date).execute
end
