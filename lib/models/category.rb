class Category < Sequel::Model
  CATEGORY_BASE_PATH = "/categories/"

  def category_page_path
    CATEGORY_BASE_PATH + Category.escape(self.name)
  end

  def self.fetch_by_name(name)
    self.where(name: name).first
  end

  def self.fetch_by_ids(category_ids)
    return [] if category_ids.empty?

    self.where(id: category_ids).to_a
  end

  def gems
    GemCategory.categorized_gems(self)
  end

  def self.escape(name)
    CGI.escape(name.gsub("/", "_"))
  end

  def self.unescape(name)
    CGI.unescape(name).gsub("_", "/")
  end

  def link
    "/categories/#{name}"
  end
end
