Sequel.migration do
  up do
    create_table(:featured, :ignore_index_errors=>true) do
      String :name, :size=>255
      String :summary, :text=>true
      Date :date
      Integer :rank
      Integer :daily_rank
      Integer :total_rank
      Integer :rank_diff
      
      primary_key [:name, :date]
      
      index [:date, :rank], :name=>:featured_combi_index
      index [:date]
      index [:rank]
    end
  end
  
  down do
    drop_table(:featured)
  end
end
