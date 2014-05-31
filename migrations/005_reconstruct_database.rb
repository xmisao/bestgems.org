Sequel.migration do
  up do
    transaction do
      create_table(:gems) do
        primary_key :id
        String :name, :size => 255
        String :version, :size => 255
        String :summary, :text => true

        index [:name]
      end

      create_table(:values) do
        primary_key :id
        Integer :type
        Integer :gem_id
        Data :date
        Integer :value

        index [:type]
        index [:gem_id]
        index [:date]
      end

      create_table(:rankings) do
        primary_key :id
        Integer :type
        Integer :gem_id
        Data :date
        Integer :ranking

        index [:type]
        index [:gem_id]
        index [:date]
      end

      create_table(:scraped_data) do
        primary_key :id
        Date :date
        String :name, :size=>255
        String :version, :size=>255
        String :summary, :text=>true
        Integer :downloads

        index [:date]
        index [:name]
      end

      drop_table(:total, :daily, :featured)
    end
  end

  down do
    raise "This migration can not be canceled."
  end
end
