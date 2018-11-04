class BestGemsApi
  def initialize(bestgems_api_base_url, api_key = nil)
    @bestgems_api_base_url, @api_key = bestgems_api_base_url, api_key
  end

  def gems(page)
    open(gems_api_endpoint(page)) { |f|
      JSON.parse(f.read)
    }
  end

  def gems_api_endpoint(page)
    "#{bestgems_api_base_url}/v2/gems.json?page=#{page}"
  end

  def trends(name)
    open(trends_api_endpoint(name)) { |f|
      JSON.parse(f.read)
    }
  end

  def trends_api_endpoint(name)
    "#{bestgems_api_base_url}/v2/gems/#{name}/trends.json"
  end

  def gems_count
    open(gems_count_api_endpoint) { |f|
      JSON.parse(f.read)
    }
  end

  def gems_count_api_endpoint
    "#{bestgems_api_base_url}/v2/statistics/gems/count.json"
  end

  def downloads_total
    open(downloads_total_api_endpoint) { |f|
      JSON.parse(f.read)
    }
  end

  def downloads_total_api_endpoint
    "#{bestgems_api_base_url}/v2/statistics/downloads/total.json"
  end

  def downloads_daily
    open(downloads_daily_api_endpoint) { |f|
      JSON.parse(f.read)
    }
  end

  def downloads_daily_api_endpoint
    "#{bestgems_api_base_url}/v2/statistics/downloads/daily.json"
  end

  def host
    @host ||= URI.parse(bestgems_api_base_url).host
  end

  def port
    @port ||= URI.parse(bestgems_api_base_url).port
  end

  def api_key
    @api_key
  end

  def put_gem(gem)
    Net::HTTP.start(host, port) do |http|
      name = gem["name"]

      req = Net::HTTP::Put.new("/api/v2/gems/#{name}.json?api_key=#{api_key}")

      req.body = gem.to_json

      http.request(req)
    end
  end

  def put_detail(detail)
    Net::HTTP.start(host, port) do |http|
      name = detail["name"]

      req = Net::HTTP::Put.new("/api/v2/gems/#{name}/detail.json?api_key=#{api_key}")

      req.body = detail.to_json

      http.request(req)
    end
  end

  def put_dependencies(dependencies)
    Net::HTTP.start(host, port) do |http|
      name = dependencies["name"]

      req = Net::HTTP::Put.new("/api/v2/gems/#{name}/dependencies.json?api_key=#{api_key}")

      req.body = dependencies.to_json

      http.request(req)
    end
  end

  def put_trends(gem, trends)
    Net::HTTP.start(host, port) do |http|
      name = gem["name"]

      req = Net::HTTP::Put.new("/api/v2/gems/#{name}/trends.json?api_key=#{api_key}")

      req.body = trends.to_json

      http.request(req)
    end
  end

  def put_gems_count(data)
    Net::HTTP.start(host, port) do |http|
      req = Net::HTTP::Put.new("/api/v2/statistics/gems/count.json?api_key=#{api_key}")

      req.body = data.to_json

      http.request(req)
    end
  end

  def put_downloads_total(data)
    Net::HTTP.start(host, port) do |http|
      req = Net::HTTP::Put.new("/api/v2/statistics/downloads/total.json?api_key=#{api_key}")

      req.body = data.to_json

      http.request(req)
    end
  end

  def put_downloads_daily(data)
    Net::HTTP.start(host, port) do |http|
      req = Net::HTTP::Put.new("/api/v2/statistics/downloads/daily.json?api_key=#{api_key}")

      req.body = data.to_json

      http.request(req)
    end
  end

  def bestgems_api_base_url
    @bestgems_api_base_url
  end
end
