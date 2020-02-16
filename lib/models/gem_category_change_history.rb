class GemCategoryChangeHistory < Sequel::Model
  class InvalidChange < StandardError; end

  many_to_one :gem, class: :Gems
  many_to_one :category, class: :Category

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

  def operation
    case change
    when "create"
      "added to"
    when "delete"
      "removed from"
    end
  end

  def operation_class_name
    "category_" + change + "d"
  end

  def self.list(limit = 100)
    eager(:gem, :category).order(:timestamp).limit(limit).reverse.all
  end
end
