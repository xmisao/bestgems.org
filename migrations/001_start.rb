Sequel.migration do
  up do
    create_table(:daily, :ignore_index_errors => true) do
      String :name, :size => 255
      String :version, :size => 255
      String :summary, :text => true
      Integer :downloads
      Date :date
      Integer :rank

      primary_key [:name, :date]

      index [:date, :downloads], :name => :daily_combi_index
      index [:date]
      index [:downloads]
    end

    create_table(:master) do
      Integer :id
      Date :date
    end

    create_table(:total, :ignore_index_errors => true) do
      String :name, :size => 255
      String :version, :size => 255
      String :summary, :text => true
      Integer :downloads
      Date :date
      Integer :rank

      primary_key [:name, :date]

      index [:date, :downloads], :name => :total_combi_index
    end
  end

  down do
    drop_table(:total, :master, :daily)
  end
end
