require "sinatra"
require "sinatra/config_file"
config_file File.expand_path("../../config/database.yml.erb", __FILE__)
Settings = settings

require "sequel"
require "cgi"
require "yaml"
require "msgpack"
require "leveldb"
require "drb/drb"
require "logger"
require "open-uri"
require "nokogiri"
require "date"

SLICE_SIZE = 1000

Sequel.split_symbols = true
Sequel::Model.require_valid_table = false

DB = Sequel.connect(settings.db)

if settings.db["adapter"] == "sqlite"
  # Suppress 'instance variable @transaction_mode not initialized' warning
  DB.transaction_mode = nil
end

require_relative "helper/trace"
require_relative "helper/web_utils"

require_relative "models/batch_logger"
require_relative "models/web_logger"
require_relative "models/model"
require_relative "models/master"
require_relative "models/scraped_data"
require_relative "models/gems"
require_relative "models/value"
require_relative "models/ranking"
require_relative "models/statistics"
require_relative "models/reports"
require_relative "models/report_data"
require_relative "models/trend"
require_relative "models/trend_data"
require_relative "models/trend_data_set"
require_relative "models/daily_summary"
require_relative "models/rubygems_page"
require_relative "models/detail"
