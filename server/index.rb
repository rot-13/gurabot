require 'sinatra'
require 'rumba'
require 'colorize'

set :root, '../'
set :public_folder, 'public'
set :roomba_port, '/dev/ttyUSB0'

begin
	roomba = Roomba.new(settings.roomba_port)
rescue Exception => e
	puts "Error connecting to Roomba (reason: #{e}).".colorize(:red)
end

get '/' do
	File.read(File.join(settings.public_folder, 'index.html'))
end

post '/command/move_forward' do
	puts "hey!"
end
