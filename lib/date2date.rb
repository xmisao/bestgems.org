#!/usr/bin/env ruby
require "date"

start_date = Date.parse(ARGV[0])
end_date = Date.parse(ARGV[1])

(start_date..end_date).each { |date|
  puts date.strftime("%Y-%m-%d")
}
