$:.unshift ::File.join(::File.dirname(__FILE__), 'lib')

require 'bundler'
Bundler.require

require 'app'

run Sinatra::Application

map '/assets' do
  run Rack::Directory.new("public")
end

map "/favicon.ico" do
  run Rack::File.new("public/favicon.ico")
end
