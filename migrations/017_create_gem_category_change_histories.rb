Sequel.migration do
  up do
    transaction do
      create_table(:gem_category_change_histories) do
        primary_key :id
        String :change
        Integer :gem_id
        Integer :category_id
        Timestamp :timestamp

        index :gem_id
        index :category_id
      end
    end
  end

  down do
    transaction do
      drop_table(:gem_category_change_histories)
    end
  end
end
