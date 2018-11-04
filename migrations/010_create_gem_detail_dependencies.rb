Sequel.migration do
  up do
    transaction do
      create_table(:dependencies) do
        primary_key :id

        Integer :gem_id
        Integer :depend_on_gem_id
        Integer :type
        String :name
        String :requirements

        index [:gem_id]
        index [:depend_on_gem_id]
      end
    end
  end

  down do
    transaction do
      drop_table(:dependencies)
    end
  end
end
