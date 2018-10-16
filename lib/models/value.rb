class Value < Sequel::Model
  module Type
    TOTAL_DOWNLOADS = 0
    DAILY_DOWNLOADS = 1
    FEATURED_SCORE = 2
  end
end
