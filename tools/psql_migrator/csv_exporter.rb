require 'sequel'
require 'formatador'
require 'csv'

class IdGenerator
  def initialize
    @id = 0
  end

  def get_id
    @id += 1
  end
end

DB = Sequel.sqlite('../../db/master.sqlite3')

Master = DB[:master]
Total = DB[:total]
Daily = DB[:daily]
Featured = DB[:featured]

TOTAL = 0
DAILY = 1
FEATURED = 2

def export_gems()
  puts 'exporting gems...'
  gems = {}
  i = 0
  name2id= {}
  count = Total.count
  started_at = Time.now
  id_generator = IdGenerator.new
  Total.order(:date).each{|total|
    i += 1
    Formatador.redisplay_progressbar(i, count, {:started_at => started_at}) if i % 1000 == 0
    if gem = gems[total[:name]]
      gems[total[:name]] = {:id => gem[:id], :name => total[:name], :version => total[:version], :summary => total[:summary]}
    else
      id = id_generator.get_id
      gems[total[:name]] = {:id => id, :name => total[:name], :version => total[:version], :summary => total[:summary]}
      name2id[total[:name]] = id
    end
  }
  puts
  CSV.open('csv/gems.csv', 'w'){|csv|
    gems.values.each{|gem|
      csv << [gem[:id], gem[:name], gem[:version], gem[:summary]]
    }
  }
  gems.clear
  name2id
end

def export_total(name2id, vig, rig)
  puts 'exporting total data...'
  count = Total.count
  started_at = Time.now
  i = 0
  total_downloads = []
  total_rank = []
  n = 0
  CSV.open('csv/values.csv', 'a'){|vcsv|
    CSV.open('csv/rankings.csv', 'a'){|rcsv|
      Total.order(:date).each{|total|
        i += 1
        Formatador.redisplay_progressbar(i, count, {:started_at => started_at}) if i % 1000 == 0
        vcsv << [vig.get_id, TOTAL, name2id[total[:name]], total[:date], total[:downloads]]
        rcsv << [rig.get_id, TOTAL, name2id[total[:name]], total[:date], total[:rank]]
      }
    }
  }
  puts
end

def export_daily(name2id, vig, rig)
  puts 'exporting daily data...'
  count = Daily.count
  started_at = Time.now
  i = 0
  daily_downloads = []
  daily_rank = []
  n = 0
  CSV.open('csv/values.csv', 'a'){|vcsv|
    CSV.open('csv/rankings.csv', 'a'){|rcsv|
      Daily.order(:date).each{|daily|
        i += 1
        Formatador.redisplay_progressbar(i, count, {:started_at => started_at}) if i % 1000 == 0
        vcsv << [vig.get_id, DAILY, name2id[daily[:name]], daily[:date], daily[:downloads]]
        rcsv << [rig.get_id, DAILY, name2id[daily[:name]], daily[:date], daily[:rank]]
      }
    }
  }
  puts
end

def export_featured(name2id, vig, rig)
  puts 'exporting featured data...'
  count = Featured.count
  started_at = Time.now
  i = 0
  daily_downloads = []
  daily_rank = []
  n = 0
  CSV.open('csv/values.csv', 'a'){|vcsv|
    CSV.open('csv/rankings.csv', 'a'){|rcsv|
      Featured.order(:date).each{|featured|
        i += 1
        Formatador.redisplay_progressbar(i, count, {:started_at => started_at}) if i % 1000 == 0
        vcsv << [vig.get_id, FEATURED, name2id[featured[:name]], featured[:date], featured[:rank_diff]]
        rcsv << [rig.get_id, FEATURED, name2id[featured[:name]], featured[:date], featured[:rank]]
      }
    }
  }
  puts
end

Dir.mkdir('csv') unless File.exist?('csv')
File.delete('csv/values.csv') if File.exist?('csv/values.csv')
File.delete('csv/rankings.csv') if File.exist?('csv/rankings.csv')

name2id = export_gems()
vig = IdGenerator.new
rig = IdGenerator.new
export_total(name2id, vig, rig)
export_daily(name2id, vig, rig)
export_featured(name2id, vig, rig)
