require 'sinatra'
require 'rumba'
require 'colorize'
require "audio-playback"
require "sinatra/namespace"


set :root, '../'
set :public_folder, 'public'
set :roomba_port, '/dev/ttyUSB0'

set :bind, '0.0.0.0' # listen on all interfaces

begin
	Roomba.new(settings.roomba_port)
rescue Exception => e
	puts "Error connecting to Roomba (reason: #{e}).".colorize(:red)
end

get '/' do
	File.read(File.join(settings.public_folder, 'index.html'))
end

namespace '/command' do
	post '/move_forward' do
		puts "hey!"
	end

	namespace '/gura' do
		[
			'akol_esh',
			'eich_aya_sofash',
			'eifo_erez',
			'eifo_matan',
			'floyd',
			'gartner',
			'gifts_project',
			'kotvim_code',
			'lama_ze_po',
			'ma_hamatzav',
			'ma_kore_po',
			'ma_ratz',
			'mi_isher_et_ze',
			'ole_1',
			'ole_2',
			'sofash_risus',
			'yesh_action'
		].each do |gura_sound|
			post "/#{gura_sound}" do
				options = {
					:channels => [0,1],
					:latency => 1
				}

				AudioPlayback.play("./server/wavs/#{gura_sound}.wav", options)

			end
		end

	end
end
