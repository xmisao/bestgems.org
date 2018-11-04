class Dependency < Sequel::Model
  DEVELOPMENT = 0
  RUNTIME = 1

  one_to_one :gem, class: "Gems", key: :id

  def self.replace_by_json(gem, json)
    DB.transaction do
      self.where(gem_id: gem.id).delete

      records = []

      records << json["dependencies"]["development"].map do |item|
        {
          gem_id: gem.id,
          depend_on_gem_id: Gems.fetch_gem_by_name(item["name"])&.id,
          type: DEVELOPMENT,
          name: item["name"],
          requirements: item["reuqirements"],
        }
      end

      records << json["dependencies"]["runtime"].map do |item|
        {
          gem_id: gem.id,
          depend_on_gem_id: Gems.fetch_gem_by_name(item["name"])&.id,
          type: RUNTIME,
          name: item["name"],
          requirements: item["reuqirements"],
        }
      end

      self.multi_insert(records.flatten)
    end
  end
end
