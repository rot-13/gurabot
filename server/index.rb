require 'sinatra'
require 'rumba'
require 'colorize'

set :root, '../'
set :public_folder, 'public'
set :roomba_port, '/dev/ttyUSB0'

set :bind, '0.0.0.0' # listen on all interfaces

begin
	Roomba.new(settings.roomba_port) do
		safe_mode
	  forward 1.meter
	  rotate :left
	  rotate -90 # degrees
	end

rescue Exception => e
	puts "Error connecting to Roomba (reason: #{e}).".colorize(:red)
end

get '/' do
	File.read(File.join(settings.public_folder, 'index.html'))
end

post '/command/move_forward' do
end
