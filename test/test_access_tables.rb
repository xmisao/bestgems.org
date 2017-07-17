require 'minitest/autorun'
require 'database'
require_relative 'run_migration'

MiniTest::Unit.autorun

class TestAccessTables < MiniTest::Unit::TestCase
  def test_access_tables
    Master.first
    Gems.first
    Value.first
    Ranking.first
    ScrapedData.first
    Reports.first
    ReportData.first
    Statistics.first
  end
end
