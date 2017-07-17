# coding: UTF-8

require 'rake/testtask'

task :default => [:test]

namespace :docker do
  desc 'Build all docker images'
  task :build do |t|
    sh 'docker build -t bestgems-web -f docker/bestgems-web/Dockerfile .'
  end

  desc 'Up all docker containers using `docker-compose up`'
  task :up do |t|
    sh 'docker-compose -f docker/docker-compose.yml up'
  end

  desc 'Run tests inside a container'
  task :test do |t|
    sh 'docker run -it --rm bestgems-web rake'
  end
end

Rake::TestTask.new do |test|
  ENV['RACK_ENV'] = 'test'
  test.test_files = Dir[ 'test/**/test_*.rb' ]
  test.verbose = true
end
