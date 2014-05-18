$:.unshift ::File.join(::File.dirname(__FILE__), 'lib')

require 'bundler'
Bundler.require

require 'app'

run Sinatra::Application

map '/bootstrap' do
  run Rack::Directory.new("public/bootstrap")
end

map '/css' do
  run Rack::Directory.new("public/css")
end

map "/favicon.ico" do
  run Rack::File.new("public/favicon.ico")
end

map "/xmisao_icon_96x96.png" do
  run Rack::File.new("public/xmisao_icon_96x96.png")
end
