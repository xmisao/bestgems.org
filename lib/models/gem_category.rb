class GemCategory < Sequel::Model
  class CategoriesCountExceeded < StandardError; end

  MAX_CATEGORIES_COUNT = 3

  def self.categorized_gems(category)
    gem_ids = self.where(category_id: category.id).select_map(:gem_id)

    Gems.fetch_by_ids(gem_ids).sort_by(&:latest_total_ranking)
  end

  def self.gem_categories(gem)
    category_ids = self.where(gem_id: gem.id).select_map(:category_id)

    Category.fetch_by_ids(category_ids)
  end

  def self.update_relations(gem, categories)
    raise CategoriesCountExceeded if categories.count > MAX_CATEGORIES_COUNT

    timestamp = Time.now

    gem_categories(gem).each do |category|
      unless categories.include?(category)
        where(gem_id: gem.id, category_id: category.id).delete
        GemCategoryChangeHistory.append_history(:delete, gem, category, timestamp)
      end
    end

    categories.each do |category|
      unless where(gem_id: gem.id, category_id: category.id).first
        insert(gem_id: gem.id, category_id: category.id)
        GemCategoryChangeHistory.append_history(:create, gem, category, timestamp)
      end
    end
  end
end
