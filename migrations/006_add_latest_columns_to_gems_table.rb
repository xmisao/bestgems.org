Sequel.migration do
  up do
    transaction do
      alter_table(:gems) do
        add_column :latest_total_downloads, Integer
        add_column :latest_total_ranking, Integer
        add_column :latest_daily_downloads, Integer
        add_column :latest_daily_ranking, Integer
        add_column :latest_update_date, Date
      end
    end
  end

  down do
    transaction do
      alter_table(:gems) do
        drop_column :latest_total_downloads
        drop_column :latest_total_ranking
        drop_column :latest_daily_downloads
        drop_column :latest_daily_ranking
        drop_column :latest_update_date
      end
    end
  end
end
