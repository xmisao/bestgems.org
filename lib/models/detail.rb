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
end
