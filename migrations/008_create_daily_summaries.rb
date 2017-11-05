Sequel.migration do
  up do
    transaction do
      create_table(:daily_summaries) do
        primary_key :id

        Date :date, unique: true, null: false
        Bignum :ranking_total_count, null: false, default: 0
        Bignum :ranking_daily_count, null: false, default: 0
      end
    end
  end

  down do
    transaction do
      drop_table(:daily_summaries)
    end
  end
end
