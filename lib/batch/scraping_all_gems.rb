require_relative '../database'

class Scraper
  RUBYGEMS_BASE_URL = 'https://rubygems.org'

  def self.execute(date, letters)
    batch_trace('Scraper', 'execute', [date, letters]){
      cleaning_gems_data(date)

      letters.each{|letter|
        num = scraping_num_of_gems(letter)
        (1..(num / 30 + 1)).each{|i|
          gems = scraping_gems_data(letter, i)
          save_gems_data(gems, date)
        }
      }
    }
  end

  def self.cleaning_gems_data(process_date)
    batch_trace('Scraper', 'cleaning_gems_data', [process_date]){
      cleaning_processed_scraped_data
      cleaning_process_date_scraped_data(process_date)
    }
  end

  def self.cleaning_processed_scraped_data
    ScrapedData.where{date <= Master.date}.delete
  end

  def self.cleaning_process_date_scraped_data(process_date)
    ScrapedData.where(date: process_date).delete
  end

  def self.scraping_num_of_gems(letter)
    batch_trace('Scraper', 'scraping_num_of_gems', [letter]){
      try(3, 60) do
        RubyGemsPage.new(letter).num_of_gems
      end
    }
  end

  def self.scraping_gems_data(letter, i)
    batch_trace('Scraper', 'scraping_gems_data', [letter, i]){
      try(3, 60) do
        RubyGemsPage.new(letter, i).gems_data
      end
    }
  end

  def self.try(times, sleep_time)
    count = 0
    begin
      yield
    rescue => e
      BatchLogger.warn(type: :retrieble_error, error_class: e.class.name, error_message: e.message, error_backtrace: e.backtrace, count: count)

      if count < times
        count += 1
        sleep sleep_time
        retry
      else
        raise e
      end
    end
  end

  def self.save_gems_data(gems, date)
    gems.each{|gem|
      gem[:date] = date
    }
    ScrapedData.multi_insert(gems)
  end
end

if $0 == __FILE__
  date = ARGV[0] || Date.today - 1
  letters = ARGV[1]
  letters ||= "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  letters = letters.split('')
  Scraper.execute(date, letters)
end
