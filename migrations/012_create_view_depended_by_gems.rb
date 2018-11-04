Sequel.migration do |arg|
  up do
    transaction do
      # Not updated gems are not displayed. (INNER JOIN)
      query = <<SQL
SELECT dependencies.depend_on_gem_id AS gem_id,
       gems.name AS name,
       gems.latest_total_ranking AS total_ranking,
       gems.latest_total_downloads AS total_downloads,
       gems.latest_update_date AS latest_update_date
FROM dependencies
JOIN master ON 1 = 1
JOIN gems ON dependencies.gem_id = gems.id AND master.date = gems.latest_update_date
SQL

      create_view(:depended_by_gems, query)
    end
  end

  down do
    transaction do
      drop_view(:depended_by_gems)
    end
  end
end
