class GemCategory < Sequel::Model
  def self.categorized_gems(category)
    gem_ids = self.where(category_id: category.id).select_map(:gem_id)

    Gems.fetch_by_ids(gem_ids).sort_by(&:latest_total_ranking)
  end

  def self.gem_categories(gem)
    category_ids = self.where(gem_id: gem.id).select_map(:category_id)

    Category.fetch_by_ids(category_ids)
  end
end
