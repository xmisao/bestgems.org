class RubyGemsApi
  RUBYGEMS_URL = 'https://rubygems.org/api/v1'

  def info(gem_name)
    open(rubygems_endpoint('/gems/?.json', gem_name)) { |f|
      JSON.parse(f.read)
    }
  end

  def rubygems_endpoint(path, param)
    RUBYGEMS_URL + path.sub('?', param)
  end
end
