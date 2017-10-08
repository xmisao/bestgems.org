require 'minitest/autorun'
require 'database'
require_relative '../run_migration'

DB.create_table! :test do
  primary_key :id
  integer :key
  integer :value
end

class Test < Sequel::Model(:test); end

class TestModel < MiniTest::Unit::TestCase
  def setup
    Test.dataset.delete
  end

  def test_insert_or_update_insert_row
    new_row = {:key => 1, :value => 1}
    result = Test.insert_or_update(new_row, :key)
    assert_equal 1, result[:key]
    assert_equal 1, result[:value]
  end

  def test_insert_or_update_update_row
    new_row = {:key => 1, :value => 1}
    Test.insert_or_update(new_row, :key)
    new_row = {:key => 1, :value => 2}
    result = Test.insert_or_update(new_row, :key)
    assert_equal 1, Test.count
    assert_equal 2, result[:value]
  end
end
