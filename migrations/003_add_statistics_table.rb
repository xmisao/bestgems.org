Sequel.migration do
  up do
    create_table(:statistics, :ignore_index_errors=>true) do
      Integer :type
      Date :date
      Bignum :value

      primary_key [:type, :date]

      index [:type]
    end
  end

  down do
    drop_table(:statistics)
  end
end
