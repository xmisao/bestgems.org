
# {
# :name=>"net-ldap",
# :summary=>"Net::LDAP for Ruby (also called net-ldap) implements client access for the\nLightweight Directory ...",
# :downloads=>436240,
# :term_start_rank=>221,
# :term_end_rank=>229,
# :rank_diff=>-8,
# :report_id=>"2013H2",
# :rank=>254
# }

Sequel.migration do
  up do
    create_table(:reports, :ignore_index_errors=>true) do
			primary_key :id
			String :name, :size => 255
			String :summary, :text => true
			String :url, :size => 32
		end

    create_table(:report_data, :ignore_index_errors=>true) do
      String :name, :size=>255
      String :summary, :text=>true
      Integer :downloads
      Integer :term_start_rank
      Integer :term_end_rank
      Integer :rank_diff
			Integer :rank
			foreign_key :report_id, :reports

      index [:report_id, :downloads], :name=>:report_data_combi_index
      index [:report_id]
      index [:downloads]
    end
  end
  
  down do
    drop_table(:report_data, :reports)
  end
end
