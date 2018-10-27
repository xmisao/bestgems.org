class Statistics < Sequel::Model
  class StatisticsMismatch < StandardError; end

  module Type
    NUM_OF_GEMS = 0
    TOTAL_DOWNLOADS = 1
    DAILY_DOWNLOADS = 2
  end

  def self.gems_count
    self.where(:type => STAT_NUM_OF_GEMS).order(:date).to_a
  end

  def self.gems_count_as_json
    {
      statistics: "gems_count",
      trends: gems_count.map(&:as_json),
    }
  end

  def self.replace_gems_count_from_json(json)
    raise StatisticsMismatch unless json["statistics"] == "gems_count"

    records = build_from_json(Type::NUM_OF_GEMS, json["trends"])

    DB.transaction do
      where(type: Type::NUM_OF_GEMS).delete
      multi_insert(records)
    end
  end

  def self.total_downloads
    self.where(:type => Type::TOTAL_DOWNLOADS).order(:date).to_a
  end

  def self.total_downloads_as_json
    {
      statistics: "total_downloads",
      trends: total_downloads.map(&:as_json),
    }
  end

  def self.replace_total_downloads_from_json(json)
    raise StatisticsMismatch unless json["statistics"] == "total_downloads"

    records = build_from_json(Type::TOTAL_DOWNLOADS, json["trends"])

    DB.transaction do
      where(type: Type::TOTAL_DOWNLOADS).delete
      multi_insert(records)
    end
  end

  def self.daily_downloads
    self.where(:type => Type::DAILY_DOWNLOADS).order(:date).to_a
  end

  def self.daily_downloads_as_json
    {
      statistics: "daily_downloads",
      trends: daily_downloads.map(&:as_json),
    }
  end

  def self.replace_daily_downloads_from_json(json)
    raise StatisticsMismatch unless json["statistics"] == "daily_downloads"

    records = build_from_json(Type::DAILY_DOWNLOADS, json["trends"])

    DB.transaction do
      where(type: Type::DAILY_DOWNLOADS).delete
      multi_insert(records)
    end
  end

  def as_json
    {
      value: value,
      date: date,
    }
  end

  def self.build_from_json(type, json)
    json.map { |hash|
      {type: type, date: hash["date"], value: hash["value"]}
    }
  end
end
