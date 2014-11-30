require 'mechanize'
require 'date'
require_relative '../database'

class Scraper
  def self.execute(date, letters)
    clear_gems_data(date)
    letters.each{|letter|
      num = scraping_num_of_gems(letter)
      (1..(num / 30 + 1)).each{|i|
        gems = scraping_gems_data(letter, i)
        save_gems_data(gems, date)
      }
      sleep 1
    }
  end

  def self.clear_gems_data(date)
    ScrapedData.where(:date => date).delete
  end

  def self.scraping_num_of_gems(letter)
    try(3, 60) do
      agent = Mechanize.new
      letter_page = agent.get("https://rubygems.org/gems?letter=#{letter}")
      letter_page.search("p[@class='gems__meter']").first.content.match(/of (\d+)/).to_a[1].to_i
    end
  end

  def self.scraping_gems_data(letter, i)
    try(3, 60) do
      agent = Mechanize.new
      page = agent.get("https://rubygems.org/gems?letter=#{letter}&page=#{i}")

      gems = []
      page.search("a[@class='gems__gem']").each{|gem|
        name_version = gem.search("h2[@class='gems__gem__name']").first.content.match(/\s*(.+)\s*(.+)/).to_a
        name = name_version[1]
        version = name_version[2]
        summary = gem.search("p[@class='gems__gem__desc t-text']").first.content.strip
        downloads = gem.search("p[@class='gems__gem__downloads__count']").first.content.gsub(/[^\d]/, '').to_i

        gems << {:name => name, :version => version, :summary => summary, :downloads => downloads}
      }
      gems
    end
  end

  def self.try(times, sleep_time)
    count = 0
    begin
      yield
    rescue
      if count < times
        count += 1
        sleep sleep_time
        retry
      else
        raise "Crawl Error"
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
