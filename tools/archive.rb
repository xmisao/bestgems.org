require_relative '../lib/database'

case ENV['RACK_ENV']
when 'development'
when 'production'
else
  puts "You should set value 'development'(to use SQLite3) or 'production'(to use PostgreSQL) to RACK_ENV environment variable."
  exit 1
end

require 'logger'
$logger = Logger.new('archive.log')

class ArchiveError < StandardError; end

class Archiver
  attr_reader :year, :month

  def initialize(year, month)
    @year, @month = year, month
  end

  def archive
    tables = ['values', 'rankings']

    tables.each{|table|
      begin
        atn = archive_table_name(table)
        unless DB.table_exists?(atn)
          $logger.info("Start create #{atn}")

          create_table_sql = generate_create_table_sql(table)
          DB.run create_table_sql

          $logger.info("End create #{atn}")
        else
          $logger.info("Skip create #{atn}")
        end

        $logger.info("Start copy #{atn}")
        copy_sql = generate_copy_sql(table)
        DB.run copy_sql
        $logger.info("End copy #{atn}")

        $logger.info("Start delete #{table} records that are copied #{atn}")
        delete_sql = generate_delete_sql(table)
        DB.run delete_sql
        $logger.info("End delete #{table} records that are copied #{atn}")
      rescue => e
        $logger.error(e)
        raise ArchiveError
      end
    }
  end

  def archive_table_name(table)
    yyyymm = sprintf('%04d%02d', year, month)

    "archived_#{table}_#{yyyymm}"
  end

  def generate_create_table_sql(table)
    tmpl = <<SQL
CREATE TABLE #{archive_table_name(table)} (
        id serial primary key,
        type integer,
        gem_id integer,
        date date,
        #{table[0..-2]} integer
);
SQL
  end

  def generate_copy_sql(table)
    first_day_of_month = sprintf('%04d-%02d-01', year, month)

    next_year = month == 12 ? year + 1 : year
    next_month = month == 12 ? 1 : month + 1

    first_day_of_next_month = sprintf('%04d-%02d-01', next_year, next_month)

    tmpl = <<SQL
INSERT INTO #{archive_table_name(table)} 
SELECT * 
FROM `#{table}` WHERE date >= '#{first_day_of_month}' AND date < '#{first_day_of_next_month}';
SQL
  end

  def generate_delete_sql(table)
    first_day_of_month = sprintf('%04d-%02d-01', year, month)

    next_year = month == 12 ? year + 1 : year
    next_month = month == 12 ? 1 : month + 1

    first_day_of_next_month = sprintf('%04d-%02d-01', next_year, next_month)

    tmpl = <<SQL
DELETE FROM `#{table}` WHERE date >= '#{first_day_of_month}' AND date < '#{first_day_of_next_month}';
SQL
  end
end


min_date = [Value.min(:date), Ranking.min(:date)].min
min_date = Date.parse(min_data) unless min_data.is_a? Date
min_date = min_date - (min_date.day - 1)

last_archive_date = Date.today - 32

raise 'No data to archive' unless min_date < last_archive_date

(min_date..last_archive_date).each{|date|
  if date.day == 1
    Archiver.new(date.year, date.month).archive
  end
}
