Sequel.migration do
  up do
    transaction do
      create_table(:gem_owners) do
        primary_key :id
        Integer :gem_id
        Integer :owner_id
        String :handle
        String :email
        DateTime :updated_at

        unique [:gem_id, :owner_id]
        index [:owner_id, :updated_at]
      end
    end
  end

  down do
    transaction do
      drop_table(:gem_owners)
    end
  end
end
