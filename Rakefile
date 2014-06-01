# coding: UTF-8

require 'rake/testtask'

task :default => [:test]

Rake::TestTask.new do |test|
  ENV['RACK_ENV'] = 'test'
  test.test_files = Dir[ 'test/**/test_*.rb' ]
  test.verbose = true
end
