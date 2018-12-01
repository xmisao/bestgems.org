class Category < Sequel::Model
  CATEGORY_BASE_PATH = '/categories/'

  def category_page_path
    CATEGORY_BASE_PATH + CGI.escape(self.name)
  end

  def self.fetch_by_name(name)
    self.where(name: name).first
  end

  def gems
    GemCategory.categorized_gems(self)
  end
end
