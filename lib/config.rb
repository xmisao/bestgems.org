module Config
  def self.trend_drb_bind_uri
    ENV["BESTGEMS_TREND_DRB_BIND_URI"] || "druby://localhost:16330"
  end

  def self.trend_drb_uri
    ENV["BESTGEMS_TREND_DRB_URI"] || "druby://localhost:16330"
  end

  def self.trend_server
    ENV["BESTGEMS_TREND_SERVER"] == "true"
  end
end
