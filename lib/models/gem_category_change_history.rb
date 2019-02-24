class GemCategoryChangeHistory < Sequel::Model
  class InvalidChange < StandardError; end

  VALID_CHANGES = [:create, :delete]

  def self.append_history(change, gem, category, timestamp)
    raise InvalidChange unless VALID_CHANGES.include?(change)

    insert(
      change: change.to_s,
      gem_id: gem.id,
      category_id: category.id,
      timestamp: timestamp,
    )
  end
end
