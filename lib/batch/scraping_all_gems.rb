require 'mechanize'
require 'date'
require_relative '../database'

class Scraper
  def self.execute(date, letters)
    letters.each{|letter|
      num = scraping_num_of_gems(letter)
      (1..(num / 30 + 1)).each{|i|
        gems = scraping_gems_data(letter, i)
        gems.each{|gem|
          save_gem_data(gem, date)
        }
      }
      sleep 1
    }
  end

  def self.scraping_num_of_gems(letter)
    agent = Mechanize.new
    letter_page = agent.get("https://rubygems.org/gems?letter=#{letter}")
    letter_page.search("p[@class='entries']").first.content.match(/of (\d+)/).to_a[1].to_i
  end

  def self.scraping_gems_data(letter, i)
    agent = Mechanize.new
    page = agent.get("https://rubygems.org/gems?letter=#{letter}&page=#{i}")

    gems = []
    page.search("div[@class='gems border']//ol//li").each{|gem|
      name_version = gem.search("a//strong").first.content.match(/(.+?)\s\((.+?)\)/).to_a
      name = name_version[1]
      version = name_version[2]
      summary = gem.search("a").children[2].content.strip
      downloads = gem.search("div//strong").first.content.gsub(/[^\d]/, '').to_i

      gems << {:name => name, :version => version, :summary => summary, :downloads => downloads}
    }
    gems
  end

  def self.save_gem_data(gem, date)
    gem[:date] = date
    ScrapedData.insert_or_update(gem, :name, :date)
  end
end

if $0 == __FILE__
  date = ARGV[0] || Date.today - 1
  letters = ARGV[1]
  letters ||= "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  letters = letters.split('')
  Scraper.execute(date, letters)
end
