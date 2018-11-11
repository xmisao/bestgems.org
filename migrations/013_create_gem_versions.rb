Sequel.migration do
  up do
    transaction do
      create_table(:gem_versions) do
        primary_key :id
        Integer :gem_id
        String :number, size: 255
        Boolean :prerelease
        Integer :downloads_count
        DateTime :built_at
        DateTime :updated_at

        index [:gem_id]
      end
    end
  end

  down do
    transaction do
      drop_table(:gem_versions)
    end
  end
end
