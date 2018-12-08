class GemOwner < Sequel::Model
  def self.replace_by_json(gem, json)
    records = json.map do |item|
      {
        gem_id: gem.id,
        owner_id: item["id"],
        handle: item["handle"],
        email: item["email"],
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
end
