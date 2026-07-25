class RubyGemsPage
  RUBYGEMS_BASE_URL = "https://rubygems.org"

  GEM_NAME_SELECTOR = "h2[@data-testid='rubygem-name']"

  Response = Data.define(:body, :final_url)

  def initialize(letter, page = 1)
    @letter, @page = letter, page
  end

  def url
    "#{RUBYGEMS_BASE_URL}/gems?letter=#{@letter}&page=#{@page}"
  end

  def html
    response.body
  end

  def doc
    @doc ||= Nokogiri::HTML.parse(html, nil, "utf8")
  end

  def gems_data
    return [] if redirected? # Out-of-range page; report no data so the scraper stops paging.

    doc.search(GEM_NAME_SELECTOR).each_with_object([]) { |name_node, gems|
      card = name_node.ancestors("a").first

      name = name_node.content.strip
      version = card.at("code")&.content&.strip
      summary = card.at("p")&.content.to_s.strip
      downloads_node = card.at_xpath(".//span[starts-with(@title, 'Total downloads')]")
      downloads = downloads_node ? downloads_node["title"].gsub(/[^\d]/, "").to_i : 0

      gems << {:name => name, :version => version, :summary => summary, :downloads => downloads}
    }
  end

  private

  def response
    @response ||= URI.open(url) { |f|
      Response.new(body: f.read, final_url: f.base_uri.to_s)
    }
  end

  # NOTE: RubyGems.org redirects out-of-range pages back to page 1 (open-uri
  #       follows it), so the final URL ends up different from the requested one.
  def redirected?
    response.final_url != url
  end
end
