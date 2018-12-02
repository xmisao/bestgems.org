Sequel.migration do
  up do
    transaction do
      create_table(:categories) do
        primary_key :id
        String :name, size: 255

        unique [:name]
      end
    end
  end

  down do
    transaction do
      drop_table(:categories)
    end
  end
end
