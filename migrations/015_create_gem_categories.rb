Sequel.migration do
  up do
    transaction do
      create_table(:gem_categories) do
        primary_key :id
        Integer :gem_id
        Integer :category_id

        unique [:gem_id, :category_id]
        unique [:category_id, :gem_id]
      end
    end
  end

  down do
    transaction do
      drop_table(:gem_categories)
    end
  end
end
