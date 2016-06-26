require 'sinatra'
require 'rumba'
require 'colorize'
require "audio-playback"
require "sinatra/namespace"
require "roomba_api"
require "espeak"

include ESpeak

set :root, '../'
set :public_folder, 'public'
set :roomba_port, '/dev/ttyUSB0'
set :roomba_baud_rate, 115200

set :bind, '0.0.0.0' # listen on all interfaces

roomba = nil

begin
	roomba = Roomba.new(settings.roomba_port, settings.roomba_baud_rate)
rescue Exception => e
	puts "Error connecting to Roomba (reason: #{e}).".colorize(:red)
end

get '/' do
	File.read(File.join(settings.public_folder, 'index.html'))
end

namespace '/command' do
	post '/move_forward' do
		RoombaApi.move_forward roomba
	end

	post '/speech' do
		text = request.body.read.to_s
		Speech.new(text, voice: "en-uk", pitch: 50, speed: 100).speak
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
					:output_device => 0
				}

				AudioPlayback.play("./server/wavs/#{gura_sound}.wav", options)

			end
		end

	end
end
