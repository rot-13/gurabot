require "sinatra"
require "sinatra/namespace"
require "colorize"
require "json"
require "./lib/roomba"

set :root, "./"
set :public_folder, "public"
set :roomba_port, "/dev/ttyUSB0"
set :roomba_baud_rate, 115200
set :bind, "0.0.0.0" # listen on all interfaces

# initialization

begin
	ROOMBA = Roomba.new(settings.roomba_port, settings.roomba_baud_rate)
	ROOMBA.full_mode if ROOMBA
	STATE = {sensors:{}, put_me_down: 0}
rescue Exception => e
	ROOMBA = nil
	STATE = {}
	puts "Error connecting to Roomba (reason: #{e}).".colorize(:red)
end

get "/" do
	File.read(File.join(settings.public_folder, "index.html"))
end

# helpers

MAX_VELOCITY = 500
SENSORS_INTERVAL = 2
PUT_ME_DOWN_SOUND = "torido_oti_"

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

def play(sound)
	system("aplay", File.absolute_path("./wavs/#{sound}.wav"))
end

def put_me_down_check
	bumps = STATE[:sensors][:bumps_and_wheel_drops]
	if bumps && bumps[:wheel_drop_right] && bumps[:wheel_drop_left]
		play("#{PUT_ME_DOWN_SOUND}#{(STATE[:put_me_down] % 3)}")
		STATE[:put_me_down] += 1
	end
end

def convert_ang_to_left_wheel(ang, vel)
	ang = ang % (Math::PI * 2)
	if 0 <= ang && ang < Math::PI * 0.5
		mult = Math.cos(ang * 2)
	elsif Math::PI * 0.5 <= ang && ang < Math::PI
		mult = -1
	elsif Math::PI <= ang && ang < Math::PI * 1.5
		mult = Math.cos((2 * ang) - Math::PI)
	else
		mult = 1
	end
	mult * vel * MAX_VELOCITY
end

# routes

namespace "/command" do
	post "/direct_control" do
		vector = request.body.read.to_s.split(",").map(&:to_f)
		vel = vector[0]
		ang = vector[1]
		left = convert_ang_to_left_wheel(ang, vel)
		right = convert_ang_to_left_wheel(ang - (Math::PI * 0.5), vel)
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

	post "/sensors" do
		command_with_return_val {
			STATE[:sensors].to_json
		}
	end

	post "/sound" do
		sound = request.body.read.to_s
		play(sound)
		"ok"
	end
end

if ROOMBA
	Thread.new do
		loop do
			sleep SENSORS_INTERVAL
			STATE[:sensors] = ROOMBA.get_sensors(0)
			put_me_down_check
		end
	end
end
