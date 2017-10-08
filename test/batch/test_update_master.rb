require 'minitest/autorun'
require 'database'
require 'batch/update_master'
require_relative '../run_migration'

class TestUpdateMaster < Minitest::Test
  def setup
    TestHelper.delete_all
  end

  def test_execute_insert
    MasterUpdater.execute(Date.new(2014, 6, 1))

    master = Master.first
    assert_equal Date.new(2014, 6, 1), master[:date]
  end

  def test_execute_update
    Master.insert(:date => Date.new(2014, 5, 31))

    MasterUpdater.execute(Date.new(2014, 6, 1))

    master = Master.first
    assert_equal 1, Master.count
    assert_equal Date.new(2014, 6, 1), master[:date]
  end

  def test_execute_exception
    Master.insert(:date => Date.new(2014, 5, 31))
    Master.insert(:date => Date.new(2014, 5, 30))

    assert_raises(RuntimeError) do
      MasterUpdater.execute(Date.new(2014, 6, 1))
    end
  end
end
