require 'sequel'
require 'yaml'
require 'pp'

env = ENV['RACK_ENV']

db_config = YAML.load_file(File.expand_path("../../config/database.yml", __FILE__))
db_config = db_config[env] || db_config[env.to_sym] || db_config
db_config.keys.each{|k| db_config[k.to_sym] = db_config.delete(k)}

DB = Sequel.connect(db_config)

class Master < Sequel::Model(:master); end
remove_const :Gem # undefine rubygems's 'Gem' module
class Gem < Sequel::Model; end
class Value < Sequel::Model; end
class Ranking < Sequel::Model; end
class ScrapedData < Sequel::Model(:scraped_data); end
class Reports < Sequel::Model; end
class ReportData < Sequel::Model(:report_data); end
class Statistics < Sequel::Model; end
