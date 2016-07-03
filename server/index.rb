require "sinatra"
require "rumba"
require "colorize"
require "sinatra/namespace"
require "espeak"

include ESpeak

set :root, '../'
set :public_folder, 'public'
set :roomba_port, '/dev/ttyUSB0'
set :roomba_baud_rate, 115200
set :bind, '0.0.0.0' # listen on all interfaces

# initialization

begin
	ROOMBA = Roomba.new(settings.roomba_port, settings.roomba_baud_rate)
	ROOMBA.full_mode if ROOMBA
rescue Exception => e
	ROOMBA = nil
	puts "Error connecting to Roomba (reason: #{e}).".colorize(:red)
end

get '/' do
	File.read(File.join(settings.public_folder, 'index.html'))
end

# helpers

MAX_VELOCITY = 500

def command
	yield if ROOMBA
	'ok'
end

def roomba_song(roomba, song_number, notes, multiplier)
		raise RangeError if song_number < 0 || song_number > 15
		notes.map! do |i|
			note, duration = i
			note = Roomba::NOTES[note] if note.is_a?(String)
			[note, duration * multiplier]
		end
		roomba.write_chars([Roomba::SONG, song_number, notes.size] + notes.flatten)
end

# routes

namespace '/command' do
	post '/direct_control' do
		vector = request.body.read.to_s.split(',').map { |val| (val.to_f * MAX_VELOCITY).floor }
		puts vector[0], vector[1]
		command { ROOMBA.drive_direct(vector[0], vector[1]) }
	end

	post '/move_forward' do
		command { ROOMBA.straight(MAX_VELOCITY) }
	end

	post '/move_backward' do
		command { ROOMBA.straight(-MAX_VELOCITY) }
	end

	post '/rotate_left' do
		command { ROOMBA.spin_left(MAX_VELOCITY) }
	end

	post '/rotate_right' do
		command { ROOMBA.spin_right(MAX_VELOCITY) }
	end

	post '/halt' do
		command { ROOMBA.halt }
	end

	post '/dock' do
		command { ROOMBA.write_chars([143]) }
	end

	post '/clean' do
		command {
			ROOMBA.write_chars([135])
		}
	end

	post '/wake' do
		command { ROOMBA.full_mode }
	end

	post '/sleep' do
		command { ROOMBA.start }
	end

	post '/songs/wrecking_ball' do
		command {
			roomba_song(ROOMBA, 3, [[70, 1], [70, 1], [70, 1], [70, 1], [70, 1], [70, 3], [69, 1] ,[69, 7], [65, 1], [70, 1], [69, 1], [67, 1], [65, 1], [70, 3], [69, 1], [69, 4]], 16)
			ROOMBA.play_song(3)
		}
	end

	post '/speech' do
		text = request.body.read.to_s
		Speech.new(text, voice: "en-uk", pitch: 50, speed: 100).speak
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
