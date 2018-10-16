class Master < Sequel::Model(:master)
  def self.date
    self.first[:date]
  end
end
