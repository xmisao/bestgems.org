class Detail < Sequel::Model
  def self.fetch_by_gem_id(gem_id)
    Detail.where(gem_id: gem_id).first
  end

  def update_by_json(json)
    self.updated_at = Time.now
    self.name = json["name"]
    self.version = json["version"]
    self.authors = json["authors"]
    self.info = json["info"]
    self.project_uri = json["project_uri"]
    self.gem_uri = json["gem_uri"]
    self.homepage_uri = json["homepage_uri"]
    self.wiki_uri = json["wiki_uri"]
    self.documentation_uri = json["documentation_uri"]
    self.mailing_list_uri = json["mailing_list_uri"]
    self.source_code_uri = json["source_code_uri"]
    self.bug_tracker_uri = json["bug_tracker_uri"]
  end

  def github_url
    [
      gem_uri,
      project_uri,
      homepage_uri,
      wiki_uri,
      documentation_uri,
      mailing_list_uri,
      source_code_uri,
      bug_tracker_uri,
    ].each do |u|
      gu = parse_github_url(u)

      return gu if gu
    end

    nil
  end

  private

  def parse_github_url(url)
    return nil unless url

    uri = URI.parse(url) rescue nil

    return nil unless uri && uri.host == "github.com"

    m = uri.path.match(/\A\/([^\/]+)\/([^\/]+)/)

    return nil unless m

    "https://github.com/#{m[1]}/#{m[2]}"
  end
end
