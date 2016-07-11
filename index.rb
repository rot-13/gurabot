require "sinatra"
require "sinatra/namespace"
require "colorize"
require "espeak"
require "json"
require "./lib/roomba"

include ESpeak

set :root, "./"
set :public_folder, "public"
set :roomba_port, "/dev/ttyUSB0"
set :roomba_baud_rate, 115200
set :bind, "0.0.0.0" # listen on all interfaces

# initialization

begin
	ROOMBA = Roomba.new(settings.roomba_port, settings.roomba_baud_rate)
	ROOMBA.full_mode if ROOMBA
rescue Exception => e
	ROOMBA = nil
	puts "Error connecting to Roomba (reason: #{e}).".colorize(:red)
end

get "/" do
	File.read(File.join(settings.public_folder, "index.html"))
end

# helpers

MAX_VELOCITY = 500

def command
	yield if ROOMBA
	"ok"
end

def command_with_return_val
	yield if ROOMBA
end

def convert_int(int)
	[int].pack("s>")
end

# routes

namespace "/command" do
	post "/direct_control" do
		vector = request.body.read.to_s.split(",").map(&:to_f)
		dir = vector[0]
		vel = vector[1]
		right = [(dir * 2) + 1, 1].min * vel * MAX_VELOCITY
		left = [(dir * -2) + 1, 1].min * vel * MAX_VELOCITY
		command { ROOMBA.drive_direct(left, right) }
	end

	post "/move_forward" do
		command { ROOMBA.straight(MAX_VELOCITY) }
	end

	post "/move_backward" do
		command { ROOMBA.straight(-MAX_VELOCITY) }
	end

	post "/rotate_left" do
		command { ROOMBA.spin_left(MAX_VELOCITY) }
	end

	post "/rotate_right" do
		command { ROOMBA.spin_right(MAX_VELOCITY) }
	end

	post "/halt" do
		command {
			ROOMBA.halt
			ROOMBA.stop_all_motors
		}
	end

	post "/dock" do
		command { ROOMBA.dock }
	end

	post "/clean" do
		command { ROOMBA.clean }
	end

	post "/wake" do
		command { ROOMBA.full_mode }
	end

	post "/sleep" do
		command { ROOMBA.start }
	end

	post "/songs/wrecking_ball" do
		command {
			ROOMBA.define_song(3, [[70, 1], [70, 1], [70, 1], [70, 1], [70, 1], [70, 3], [69, 1] ,[69, 7], [65, 1], [70, 1], [69, 1], [67, 1], [65, 1], [70, 3], [69, 1], [69, 4]], 16)
			ROOMBA.play_song(3)
		}
	end

	post "/speech" do
		text = request.body.read.to_s
		Speech.new(text, voice: "en-uk", pitch: 50, speed: 100).speak
		"ok"
	end

	post "/sensors" do
		command_with_return_val {
			data = ROOMBA.get_sensors(3)
			data.to_json
		}
	end

	post "/sound" do
		sound = request.body.read.to_s
		system("aplay", File.absolute_path("./wavs/#{sound}.wav"))
		"ok"
	end
end
