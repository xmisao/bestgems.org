class RubyGemsApi
  RUBYGEMS_URL = "https://rubygems.org/api/v1"

  def info(gem_name)
    URI.open(rubygems_endpoint("/gems/?.json", gem_name)) { |f|
      JSON.parse(f.read)
    }
  rescue OpenURI::HTTPError => e
    nil
  end

  def versions(gem_name)
    URI.open(rubygems_endpoint("/versions/?.json", gem_name)) { |f|
      JSON.parse(f.read)
    }
  rescue OpenURI::HTTPError => e
    nil
  end

  def owners(gem_name)
    URI.open(rubygems_endpoint("/gems/?/owners.json", gem_name)) { |f|
      JSON.parse(f.read)
    }
  rescue OpenURI::HTTPError => e
    nil
  end

  def rubygems_endpoint(path, param)
    RUBYGEMS_URL + path.sub("?", param)
  end
end
