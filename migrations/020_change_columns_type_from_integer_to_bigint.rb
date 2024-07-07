Sequel.migration do
  up do
    transaction do
      drop_view(:depended_by_gems)
      drop_view(:depends_on_gems)

      alter_table(:gems) do
        set_column_type :latest_total_downloads, :Bignum
      end

      alter_table(:values) do
        set_column_type :value, :Bignum
      end

      alter_table(:scraped_data) do
        set_column_type :downloads, :Bignum
      end

      query1 = <<SQL
SELECT dependencies.depend_on_gem_id AS gem_id,
       gems.name AS name,
       gems.latest_total_ranking AS total_ranking,
       gems.latest_total_downloads AS total_downloads,
       gems.latest_update_date AS latest_update_date
FROM dependencies
JOIN gems ON dependencies.gem_id = gems.id
WHERE gems.latest_update_date = (SELECT date FROM master LIMIT 1)
SQL
      create_or_replace_view(:depended_by_gems, query1)

      query2 = <<SQL
SELECT dependencies.gem_id AS gem_id,
       dependencies.name AS name,
       gems.latest_total_ranking AS total_ranking,
       gems.latest_total_downloads AS total_downloads,
       gems.latest_update_date AS latest_update_date
FROM dependencies
JOIN master ON 1 = 1
LEFT OUTER JOIN gems ON dependencies.depend_on_gem_id = gems.id AND master.date = gems.latest_update_date
SQL
      create_view(:depends_on_gems, query2)
    end
  end
end
