def parse_date(date_str)
  begin
    Date.parse(date_str)
  rescue ArgumentError
    nil
  end
end
