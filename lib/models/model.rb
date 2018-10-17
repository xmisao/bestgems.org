class Sequel::Model
  def self.insert_or_update(new_row, *keys)
    raise "Keys are not specified." if keys.length == 0
    query = {}
    keys.each { |key|
      raise "Key value does not exist." unless new_row[key]
      query[key] = new_row[key]
    }
    old_row = self.where(query)
    case old_row.count
    when 0
      id = self.insert(new_row)
      self[id]
    when 1
      old_row.update(new_row)
      id = old_row.first[:id]
      self[id]
    else
      raise "There are the plural rows."
    end
  end
end
