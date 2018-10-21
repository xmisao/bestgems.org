$:.unshift ::File.join(::File.dirname(__FILE__), 'lib')

require 'bundler'
Bundler.require

require 'app'

Rack::Utils.key_space_limit = 1024 * 1024 * 2 # FIXME

run Sinatra::Application

map '/assets' do
  run Rack::Directory.new("public/assets")
end

map "/favicon.ico" do
  run Rack::File.new("public/assets/images/favicon.ico")
end
