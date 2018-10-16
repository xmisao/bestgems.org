class RubyGemsPage
  RUBYGEMS_BASE_URL = 'https://rubygems.org'

  def initialize(letter, page = 1)
    @letter, @page = letter, page
  end

  def html
    @html ||= open(url){|f| f.read }
  end

  def doc
    @doc ||= Nokogiri::HTML.parse(html, nil, "utf8")
  end

  def url
    "#{RUBYGEMS_BASE_URL}/gems?letter=#{@letter}&page=#{@page}"
  end

  def num_of_gems
    doc.at("p[@class='gems__meter']").content.match(/of (\d+)/).to_a[1].to_i
  end

  def gems_data
    doc.search("a[@class='gems__gem']").each_with_object([]){|gem, gems|
      name_version = gem.at("h2[@class='gems__gem__name']").content.match(/\s*(.+)\s*(.+)/).to_a
      name = name_version[1]
      version = name_version[2]
      summary = gem.at("p[@class='gems__gem__desc t-text']").content.strip
      downloads = gem.at("p[@class='gems__gem__downloads__count']").content.gsub(/[^\d]/, '').to_i

      gems << {:name => name, :version => version, :summary => summary, :downloads => downloads}
    }
  end
end
