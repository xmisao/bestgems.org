require 'sinatra'
require 'sinatra/config_file'
config_file File.expand_path('../../../config/database.yml.erb', __FILE__)

require 'sequel'

class Migrator
  def initialize(database_setting)
    @database_setting = database_setting
  end

  def execute_migration

    puts 'Start migrations...'

    Sequel.extension :migration

    Sequel::Migrator.run(
      Sequel.connect(@database_setting),
      File.expand_path('../../../migrations', __FILE__)
    )

    puts 'Migraions Done!'
  end
end
