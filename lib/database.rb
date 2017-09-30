require 'sinatra'
require 'sinatra/config_file'
config_file File.expand_path('../../config/database.yml.erb', __FILE__)

require 'sequel'
require 'cgi'
require 'yaml'
require 'msgpack'
require 'leveldb'

SLICE_SIZE = 1000

DB = Sequel.connect(settings.db)
require_relative 'models/model'
require_relative 'models/master'
require_relative 'models/scraped_data'
require_relative 'models/gems'
require_relative 'models/value'
require_relative 'models/ranking'
require_relative 'models/statistics'
require_relative 'models/reports'
require_relative 'models/report_data'
require_relative 'models/trend'
require_relative 'models/trend_data'
