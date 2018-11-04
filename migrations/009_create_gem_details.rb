Sequel.migration do
  up do
    transaction do
      create_table(:details) do
        primary_key :id

        Integer :gem_id
        DateTime :updated_at
        String :name, size: 255
        String :version, size: 255
        String :authors, text: true
        String :info, text: true
        String :project_uri, size: 255
        String :gem_uri, size: 255
        String :homepage_uri, size: 255
        String :wiki_uri, size: 255
        String :documentation_uri, size: 255
        String :mailing_list_uri, size: 255
        String :source_code_uri, size: 255
        String :bug_tracker_uri, size: 255

        unique [:gem_id]
        unique [:name]
      end
    end
  end

  down do
    transaction do
      drop_table(:details)
    end
  end
end
