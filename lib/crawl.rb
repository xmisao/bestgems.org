require 'sequel'
require 'mechanize'
require 'date'

DB = Sequel.sqlite('db/master.sqlite3', :timeout => 60000)
total = DB[:total]

LETTERS = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z']

agent = Mechanize.new

LETTERS.each{|letter|

  STDERR.puts "downloading... #{letter}."

  letter_page = agent.get("https://rubygems.org/gems?letter=#{letter}")

  gems = letter_page.search("p[@class='entries']").first.content.match(/of (\d+)/).to_a[1].to_i

  agent.back

  (1..(gems / 30 + 1)).each{|i|
    page = agent.get("https://rubygems.org/gems?letter=#{letter}&page=#{i}")

    page.search("div[@class='gems border']//ol//li").each{|gem|
      name_version = gem.search("a//strong").first.content.match(/(.+?)\s\((.+?)\)/).to_a
      name = name_version[1]
      version = name_version[2]
      summary = gem.search("a").children[2].content.strip
      downloads = gem.search("div//strong").first.content.gsub(/[^\d]/, '').to_i
      date = (Date::today - 1).to_s

      row = total.where(:name => name, :date => date)
      if row.count > 0
        STDERR.puts "update #{name} at #{date}"
        row.update(:version => version, :summary => summary, :downloads => downloads)
      else
        STDERR.puts "insert #{name} at #{date}"
        total.insert(:name => name, :version => version, :summary => summary, :downloads => downloads, :date => date)
      end
    }

    agent.back
  }

  sleep 1
}
