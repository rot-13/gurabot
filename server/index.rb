require 'sinatra'
require 'rumba'
require 'colorize'
require "audio-playback"
require "sinatra/namespace"
require_relative "./roomba_api"
require "espeak"

include RoombaApi
include ESpeak

set :root, '../'
set :public_folder, 'public'
set :roomba_port, '/dev/ttyUSB0'
set :roomba_baud_rate, 115200
set :bind, '0.0.0.0' # listen on all interfaces

begin
	roomba = Roomba.new(settings.roomba_port, settings.roomba_baud_rate)
	roomba.full_mode if roomba
rescue Exception => e
	puts "Error connecting to Roomba (reason: #{e}).".colorize(:red)
end

get '/' do
	File.read(File.join(settings.public_folder, 'index.html'))
end


namespace '/info' do
	get '/battery' do
		RoombaApi.battery_percentage(roomba)
	end
end

namespace '/command' do
	post '/move_forward' do
		RoombaApi.forward roomba
		'ok'
	end

	post '/move_backward' do
		RoombaApi.backward roomba
		'ok'
	end

	post '/rotate_left' do
		RoombaApi.left roomba
		'ok'
	end

	post '/rotate_right' do
		RoombaApi.right roomba
		'ok'
	end

	post '/halt' do
		RoombaApi.halt roomba
		'ok'
	end

	post '/dock' do
		RoombaApi.dock roomba
		'ok'
	end

	post '/clean' do
		RoombaApi.clean roomba
		'ok'
	end

	post '/wake' do
		RoombaApi.wake roomba
		'ok'
	end

	post '/sleep' do
		RoombaApi.sleep roomba
		'ok'
	end

	post '/songs/wrecking_ball' do
		RoombaApi.wrecking_ball roomba
		'ok'
	end

	post '/speech' do
		text = request.body.read.to_s
		Speech.new(text, voice: "en-uk", pitch: 50, speed: 100).speak
		'ok'
	end

	post '/dock' do
		RoombaApi.dock roomba
		'ok'
	end

	post '/clean' do
		RoombaApi.clean roomba
		'ok'
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
				system("aplay", File.absolute_path("./server/wavs/#{gura_sound}.wav"))
				'ok'
			end
		end

	end
end
