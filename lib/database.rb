require 'sequel'
require 'yaml'

env = ENV['RACK_ENV']

db_config = YAML.load_file(File.expand_path("../../config/database.yml", __FILE__))
db_config = db_config[env] || db_config[env.to_sym] || db_config
db_config.keys.each{|k| db_config[k.to_sym] = db_config.delete(k)}

SLICE_SIZE = 10000

DB = Sequel.connect(db_config)
require_relative 'models/model'
require_relative 'models/master'
require_relative 'models/scraped_data'
require_relative 'models/gems'
require_relative 'models/value'
require_relative 'models/ranking'
require_relative 'models/statistics'
require_relative 'models/reports'
require_relative 'models/report_data'
