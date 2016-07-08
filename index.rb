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
	@roomba = Roomba.new(settings.roomba_port, settings.roomba_baud_rate)
	@roomba.full_mode if @roomba
rescue Exception => e
	@roomba = nil
	puts "Error connecting to Roomba (reason: #{e}).".colorize(:red)
end

get "/" do
	File.read(File.join(settings.public_folder, "index.html"))
end

# helpers

MAX_VELOCITY = 500

def command
	yield if @roomba
	"ok"
end

def command_with_return_val
	yield if @roomba
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
		command { @roomba.drive_direct(left, right) }
	end

	post "/move_forward" do
		command { @roomba.straight(MAX_VELOCITY) }
	end

	post "/move_backward" do
		command { @roomba.straight(-MAX_VELOCITY) }
	end

	post "/rotate_left" do
		command { @roomba.spin_left(MAX_VELOCITY) }
	end

	post "/rotate_right" do
		command { @roomba.spin_right(MAX_VELOCITY) }
	end

	post "/halt" do
		command {
			@roomba.halt
			@roomba.stop_all_motors
		}
	end

	post "/dock" do
		command { @roomba.dock }
	end

	post "/clean" do
		command { @roomba.clean }
	end

	post "/wake" do
		command { @roomba.full_mode }
	end

	post "/sleep" do
		command { @roomba.start }
	end

	post "/songs/wrecking_ball" do
		command {
			@roomba.define_song(3, [[70, 1], [70, 1], [70, 1], [70, 1], [70, 1], [70, 3], [69, 1] ,[69, 7], [65, 1], [70, 1], [69, 1], [67, 1], [65, 1], [70, 3], [69, 1], [69, 4]], 16)
			@roomba.play_song(3)
		}
	end

	post "/speech" do
		text = request.body.read.to_s
		Speech.new(text, voice: "en-uk", pitch: 50, speed: 100).speak
		"ok"
	end

	post "/sensors" do
		command_with_return_val {
			data = @roomba.get_sensors(3)
			data.to_json
		}
	end

	post "/sound" do
		sound = request.body.read.to_s
		system("aplay", File.absolute_path("./wavs/#{sound}.wav"))
		"ok"
	end
end
