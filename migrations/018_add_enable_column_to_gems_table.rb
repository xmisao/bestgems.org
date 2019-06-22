Sequel.migration do
  up do
    transaction do
      alter_table(:gems) do
        add_column :enable, TrueClass, null: false, default: true
      end
    end
  end

  down do
    transaction do
      alter_table(:gems) do
        drop_column :enable
      end
    end
  end
end
