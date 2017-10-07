class Trend
  LEVELDB_DIR = Settings.leveldb['dir']

  @@level_db = LevelDB::DB.new LEVELDB_DIR

  def self.get_a(key)
    unpack(@@level_db[key])
  end

  def self.put_a(key, td_list)
    @@level_db[key] = pack(td_list) if td_list
  end

  def self.delete_a(key)
    @@level_db.delete(key)
  end

  def self.all(&blk)
    @@level_db.each{|k, v|
      blk.call(k, unpack(v))
    }
  end

  def self.get(gem_id)
    from = "#{gem_id}.0"
    to = "#{gem_id}.9"

    td_list = []

    @@level_db.each(from: from, to: to){|_, value|
      td_list += unpack(value) if value
    }
    
    td_list.sort_by{|td| td.date }
  end

  def self.put(gem_id, *td_list)
    raise ArgumentError if td_list.size == 0

    td_list.group_by{|td| td.key(gem_id) }.each{|key, monthly_td_list|
      update(key, monthly_td_list)
    }
  end

  def self.update(key, td_list)
    if exist_td_list = get_a(key)
      merged_td_list = merge_td_list(exist_td_list, td_list)

      put_a(key, merged_td_list)
    else
      put_a(key, td_list)
    end
  end

  def self.merge_td_list(exist_td_list, new_td_list)
    hash = {}

    exist_td_list.each{|td|
      hash[td.date] = td
    }

    new_td_list.each{|td|
      hash[td.date] = td
    }

    hash.values
  end

  def self.empty?
    @@level_db.each{|_|
      return false
    }

    true
  end

  private

  def self.unpack(value)
    MessagePack.unpack(value) if value
  end

  def self.pack(td_list)
    MessagePack.pack(td_list)
  end
end
