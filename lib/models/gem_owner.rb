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

  def self.gem_owners(gem)
    self.where(gem_id: gem.id).to_a
  end

  def handle_for_display
    return "(Unknown)" if handle.nil? || handle.empty?

    handle
  end

  def gravatar_image_url
    "https://www.gravatar.com/avatar/#{gravatar_image_hash}?s=48"
  end

  def gravatar_image_hash
    if email.nil? || email.empty? || email.strip.empty?
      "HASH"
    else
      Digest::MD5.hexdigest(email.strip.downcase)
    end
  end
end
