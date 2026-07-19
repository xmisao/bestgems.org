#!/usr/bin/env ruby
# frozen_string_literal: true

# Live smoke test for the RubyGems.org scraper: fetch a tiny slice and check the
# parser still matches the site's HTML. Run it to confirm scraping health or when
# data stops updating.
#
# Usage: ruby tools/verify_scraping.rb [LETTER] [PAGE]
# Exit:  0 = OK, 1 = broken (update lib/models/rubygems_page.rb).

require "open-uri"
require "nokogiri"
require_relative "../lib/models/rubygems_page"

letter = ARGV[0] || "A"
page_no = (ARGV[1] || "1").to_i

failures = []

def check(failures, desc)
  ok = yield
  puts "#{ok ? "OK  " : "NG  "} #{desc}"
  failures << desc unless ok
  ok
rescue => e
  puts "NG  #{desc} (#{e.class}: #{e.message})"
  failures << desc
  false
end

puts "== RubyGems.org scraping check: letter=#{letter} page=#{page_no} =="

page = RubyGemsPage.new(letter, page_no)
gems = nil
check(failures, "fetch & parse the page") { gems = page.gems_data; true }

check(failures, "at least one gem parsed (HTML structure matched)") { gems && !gems.empty? }

if gems && !gems.empty?
  puts "  parsed #{gems.size} gems, e.g.:"
  gems.first(3).each { |g| puts "    - #{g[:name]} #{g[:version]} / downloads=#{g[:downloads]} / #{g[:summary]}" }

  check(failures, "every gem has a name")        { gems.all? { |g| g[:name] && !g[:name].empty? } }
  check(failures, "every gem has a version")     { gems.all? { |g| g[:version] && !g[:version].empty? } }
  check(failures, "every gem has a download count") { gems.all? { |g| g[:downloads].is_a?(Integer) } }
  check(failures, "at least one gem has downloads > 0") { gems.any? { |g| g[:downloads] > 0 } }
end

# Pagination termination: an out-of-range page must yield no gems, otherwise the
# scraper would re-scrape page 1 up to MAX_FETCH_PAGES times per letter.
check(failures, "out-of-range page yields no gems (paging stops)") do
  RubyGemsPage.new(letter, 99_999).gems_data.empty?
end

puts
if failures.empty?
  puts "RESULT: OK — the scraper works against the live RubyGems.org."
  exit 0
else
  puts "RESULT: NG — #{failures.size} check(s) failed:"
  failures.each { |f| puts "  - #{f}" }
  puts
  puts "RubyGems.org's HTML likely changed. Update the selectors in"
  puts "lib/models/rubygems_page.rb (and re-run this script)."
  exit 1
end
