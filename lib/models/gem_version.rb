class GemVersion < Sequel::Model
  one_to_one :gem, class: "Gems", key: :id

  def self.replace_by_json(gem, json)
    records = json.map do |item|
      {
        gem_id: gem.id,
        number: item["number"],
        prerelease: item["prerelease"],
        downloads_count: item["downloads_count"],
        built_at: item["built_at"],
        updated_at: Time.now,
      }
    end

    return false if records.count == 0

    DB.transaction do
      self.where(gem_id: gem.id).delete
      self.multi_insert(records)
    end

    true
  end

  def numbers
    @numbers ||= number.scan(/\d+/)
  end

  def major_version
    @major_version ||= numbers[0].to_s
  end

  def major_minor_version
    @major_minor_version ||= numbers[0..1].join(".")
  end
end
