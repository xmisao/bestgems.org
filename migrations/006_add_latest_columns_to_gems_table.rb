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
    raise "This migration can not be canceled."
  end
end
