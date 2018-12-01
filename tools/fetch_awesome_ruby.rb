require_relative "../lib/database"
require 'rake'
require 'pp'
require 'csv'
require 'open-uri'

AWESOME_RUBY_DIR = '/tmp/awesome-ruby'

unless FileTest.exist?(AWESOME_RUBY_DIR)
  sh "git clone 'https://github.com/markets/awesome-ruby.git' #{AWESOME_RUBY_DIR}"
end

README_PATH = AWESOME_RUBY_DIR + '/README.md'

# CategoryEntry = Struct.new(:category, :name, :url, :description, keyword_init: true)

class CategoryEntry
  attr_reader :category, :name, :url, :description

  def initialize(category:, name:, url:, description:)
    @category, @name, @url, @description = category, name, url, description
  end

  def gems_by_project_uri
    @gems_by_project_uri ||= Detail.where(project_uri: @url).to_a
  end

  def gems_by_gem_uri
    @gems_by_gem_uri ||= Detail.where(gem_uri: @url).to_a
  end

  def gems_by_homepage_uri
    @gems_by_homepage_uri ||= Detail.where(homepage_uri: @url).to_a
  end

  def gems_by_source_code_uri
    @gems_by_source_code_uri ||= Detail.where(source_code_uri: @url).to_a
  end

  def gems_by_name
    @gems_by_name ||= Gems.where(name: @name.downcase).to_a
  end

  def gem_by_uri_best
    gems = [
      gems_by_project_uri,
      gems_by_gem_uri,
      gems_by_homepage_uri,
      gems_by_source_code_uri
    ].flatten

    max_gems = gems.group_by(&:gem_id).sort_by{|(id, gds)| gds.count}

    return nil if max_gems.nil?
    return nil if max_gems.empty?

    if max_gems.count == 1 || max_gems[0][1].count != max_gems[1][1].count
      return Gems.where(id: max_gems[0][0]).first
    else
      # pp max_gems
    end

    nil
  end

  def gem_by_name_best
    downcased_name = @name.downcase
    g = Gems.where(name: downcased_name).first
    return g if g

    if @name.match(/\s+/)
      cand_name = @name.gsub(/\s+/, '-').downcase
      g = Gems.where(name: cand_name).first
      return g if g

      cand_name = @name.gsub(/\s+/, '_').downcase
      g = Gems.where(name: cand_name).first
      return g if g
    end

    if @name.match(/:+/)
      cand_name = @name.gsub(/:+/, '-').downcase
      g = Gems.where(name: cand_name).first
      return g if g

      cand_name = @name.gsub(/:+/, '_').downcase
      g = Gems.where(name: cand_name).first
      return g if g
    end

    splited = @name.split(/(?<=[a-z])(?=[A-Z])/).map(&:downcase)

    if splited.count >= 2
      cand_name = splited.join('-')
      g = Gems.where(name: cand_name).first
      return g if g

      cand_name = splited.join('_')
      g = Gems.where(name: cand_name).first
      return g if g
    end

    nil
  end

  def gem_by_github_gemspec
    fetch_gemspec_by_url(@url)
  end

  def fetch_gemspec_by_url(url)
    return nil unless url

    if url.match(/github.com/)
      return open(url){|f| f.read.match(/([\w-]+)\.gemspec/).to_a[1] }
    end

    nil
  rescue => e
    nil
  end
end

puts Detail.count

category_entries = open(README_PATH) do |f|
  category = nil
  category_entries = {}

  f.each_line do |l|
    l = l.unicode_normalize(:nfkc)
    if m = l.match(/##(.+)$/)
      category = m.to_a[1].strip
      category_entries[category] = []
    elsif m = l.match(/^#/)
      category = nil
    elsif m = l.match(/\* \[(.+?)\]\((.+?)\)\s[-–]\s(.+)$/)
      next unless category

      name = m.to_a[1].strip
      url = m.to_a[2].strip
      description = m.to_a[3].strip

      entry = CategoryEntry.new(
        category: category,
        name: name,
        url: url,
        description: description
      )

      category_entries[category] << entry
    else
      # puts l unless l.strip.empty?
    end
  end

  category_entries.values.flatten
end

failed = 0
success = 0

category_entries.each do |category_entry|
  unless category_entry.gem_by_name_best || category_entry.gem_by_uri_best
    failed += 1
  else
    success += 1
  end

  puts [
    category_entry.category,
    category_entry.name,
    category_entry.url,
    category_entry.gem_by_name_best&.name,
    category_entry.gem_by_uri_best&.name,
    category_entry.gem_by_github_gemspec
  ].to_csv

  STDOUT.flush
end

puts success
puts failed
