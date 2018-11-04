class DependedByGem < Sequel::Model
  def self.fetch_by_gem_id(gem_id, limit: 20)
    where(gem_id: gem_id).order(:total_ranking).limit(limit).to_a
  end
end
