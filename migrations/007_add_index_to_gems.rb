Sequel.migration do
  up do
    transaction do
      alter_table(:gems) do
        add_index [:latest_update_date, :latest_total_ranking]
        add_index [:latest_update_date, :latest_daily_ranking]
      end
    end
  end

  down do
    transaction do
      alter_table(:gems) do
        drop_index [:latest_update_date, :latest_total_ranking]
        drop_index [:latest_update_date, :latest_daily_ranking]
      end
    end
  end
end
