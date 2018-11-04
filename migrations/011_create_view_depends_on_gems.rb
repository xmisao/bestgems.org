Sequel.migration do |arg|
  up do
    transaction do
      # Not updated gems are displayed name only. (LEFT OUTER JOIN)
      query = <<SQL
SELECT dependencies.gem_id AS gem_id,
       dependencies.name AS name,
       gems.latest_total_ranking AS total_ranking,
       gems.latest_total_downloads AS total_downloads,
       gems.latest_update_date AS latest_update_date
FROM dependencies
JOIN master ON 1 = 1
LEFT OUTER JOIN gems ON dependencies.depend_on_gem_id = gems.id AND master.date = gems.latest_update_date
SQL

      create_view(:depends_on_gems, query)
    end
  end

  down do
    transaction do
      drop_view(:depends_on_gems)
    end
  end
end
