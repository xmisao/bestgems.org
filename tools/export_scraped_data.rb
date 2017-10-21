require_relative '../lib/database'

case ENV['RACK_ENV']
when 'development'
when 'production'
else
  puts "You should set value 'development'(to use SQLite3) or 'production'(to use PostgreSQL) to RACK_ENV environment variable."
  exit 1
end

require 'logger'
$logger = Logger.new('export_scraped_data.log')

class ScrapedDataExporter
  def self.export(date, file)
    open(file, 'w'){|f|
      ScrapedData.where(:date => date).order(:name).each{|data|
        data_hash = {
          :date => data[:date],
          :name => data[:name],
          :version => data[:version],
          :summary => data[:summary],
          :downloads => data[:downloads]
        }
        f.puts data_hash.to_json
      }
    }
  end
end

raise 'Usage: export_scraped_data.rb date file' unless ARGV.size == 2

begin
  date = ARGV[0]
  file = ARGV[1]
  ScrapedDataExporter.export(date, file)
rescue => e
  $logger.error e
  raise
end
