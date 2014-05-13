require 'sinatra'
load 'app.rb'

run Sinatra::Application

map '/bootstrap' do
	run Rack::Directory.new("./bootstrap")
end

map '/css' do
	run Rack::Directory.new("./css")
end

map "/favicon.ico" do
    run Rack::File.new("./favicon.ico")
end

map "/xmisao_icon_96x96.png" do
    run Rack::File.new("./xmisao_icon_96x96.png")
end
