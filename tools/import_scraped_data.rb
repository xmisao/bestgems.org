require_relative '../lib/database'

case ENV['RACK_ENV']
when 'development'
when 'production'
else
  puts "You should set value 'development'(to use SQLite3) or 'production'(to use PostgreSQL) to RACK_ENV environment variable."
  exit 1
end

require 'logger'
$logger = Logger.new('import_scraped_data.log')

class ScrapedDataImporter
  def self.import(file)
    $logger.info("Start import #{file}")

    open(file){|f|
      f.each_line.each_slice(1000).each_with_index{|lines, i|
        $logger.info("Importing part... #{i}")

        records = []

        lines.each{|l|
          data = JSON.parse(l)
          records << data
        }

        ScrapedData.multi_insert records
      }
    }

    $logger.info("End import #{file}")
  end
end

# Usage: import_scraped_data.rb FILE...

begin
  ARGV.each{|file|
    ScrapedDataImporter.import(file)
  }
rescue => e
  $logger.error e
  raise
end
