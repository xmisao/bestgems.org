require 'sinatra'
require 'sinatra/config_file'
config_file File.expand_path('../../../config/database.yml.erb', __FILE__)

require 'sequel'

require 'logger'
require 'date'

class Migrator
  def initialize(database_setting)
    @database_setting = database_setting
    @logger = Logger.new(STDOUT)
    @logger.info("Database setting #{@database_setting.inspect}")
  end

  def execute_migration
    @logger.info('Migration started.')

    Sequel.extension :migration

    Sequel::Migrator.run(
      Sequel.connect(@database_setting),
      File.expand_path('../../../migrations', __FILE__)
    )

    @logger.info('Migration finished.')
  rescue => e
    @logger.fatal e.inspect
    @logger.fatal e.backtrace
    exit 1
  end

  def insert_initial_data
    @logger.info('Insert initial data started.')

    Sequel.connect(@database_setting) do |db|
      if db[:master].count == 0
        db[:master].insert(date: Date.today)
      end
    end

    @logger.info('Insert initial data finished.')
  rescue => e
    @logger.fatal e.inspect
    @logger.fatal e.backtrace
    exit 1
  end
end
