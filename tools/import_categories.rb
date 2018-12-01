require_relative '../lib/database.rb'
require 'csv'

log = Logger.new(STDOUT)

categories = CSV.foreach(ARGV[0], headers: true).map{|row|
  category = row['category']
}.uniq

categories.each do |name|
  c = Category.where(name: name).first

  unless c
    Category.insert(name: name)
  else
    log.info(type: :category_already_exists, category: name)
  end
end

CSV.foreach(ARGV[0], headers: true) do |row|
  category = row['category']
  gem_name = row['gem_name']

  c = Category.where(name: category).first

  g = Gems.where(name: gem_name).first

  if g
    gc = GemCategory.where(category_id: c.id, gem_id: g.id).first

    unless gc
      GemCategory.insert(category_id: c.id, gem_id: g.id)
    else
      log.info(type: :already_exists, category: category, gem_name: gem_name)
    end
  else
    log.info(type: :gem_not_forund, gem_name: gem_name)
  end
end
