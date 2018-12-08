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

  def self.fetch_latest_by_owner_id(owner_id)
    where(owner_id: owner_id).order(:updated_at).last
  end

  def self.owned_gems(owner_id)
    gem_ids = where(owner_id: owner_id).select_map(:gem_id)

    Gems.fetch_by_ids_ordered_by_total_downloads(gem_ids)
  end

  def handle_for_display
    return "##{owner_id}" if handle.nil? || handle.empty?

    handle
  end

  def gravatar_image_url(s = 48)
    "https://www.gravatar.com/avatar/#{gravatar_hash}?s=#{s}"
  end

  def gravatar_profile_url
    if valid_email?
      "https://www.gravatar.com/#{gravatar_hash}"
    else
      nil
    end
  end

  def gravatar_hash
    if valid_email?
      Digest::MD5.hexdigest(email.strip.downcase)
    else
      "HASH"
    end
  end

  def valid_email?
    !(email.nil? || email.empty? || email.strip.empty?)
  end

  def owner_page_path
    "/owners/#{owner_id}"
  end
end
