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

BEHAVIORS = JSON.parse(File.read('./behaviors.json'))

# helpers

MAX_VELOCITY = 500
SENSORS_INTERVAL = 1
LIFT_CHECK_INTERVAL = 2
DOCK_CHECK_INTERVAL = 10
PUT_ME_DOWN_SOUND = "torido_oti_"

BEHAVIOR_HALT     = "🚫"
BEHAVIOR_SFX      = "🎵"
BEHAVIOR_LEFT     = "◀"
BEHAVIOR_RIGHT    = "▶"
BEHAVIOR_FORWARD  = "▲"
BEHAVIOR_BACKWARD = "▼"

def command
	yield if ROOMBA
	"ok"
end

def command_in_full_mode
	if ROOMBA
		ROOMBA.full_mode if docked?
		yield
	end
	"ok"
end

def command_with_return_val
	yield if ROOMBA
end

def docked?
	STATE[:docked]
end

def convert_int(int)
	[int].pack("s>")
end

def play(sound)
	system("aplay", File.absolute_path("./wavs/#{sound}.wav"))
end

def lift_check
	bumps = STATE[:sensors][:bumps_and_wheel_drops]
	if bumps && bumps[:wheel_drop_right] && bumps[:wheel_drop_left]
		play("#{PUT_ME_DOWN_SOUND}#{(STATE[:put_me_down] % 2)}")
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

def play_behavior(name)
	behavior = BEHAVIORS[name]
	behavior_array = []

	behavior.each do |command|
		if command[0] == "$"
			behavior_array += BEHAVIORS[command[1..-1]]
		else
			behavior_array << command
		end
	end
	behavior_array << BEHAVIOR_HALT

	behavior_array.each do |command|
		instruction = command.match(/(?<type>.)(\[(?<velocity>.*)\])?(\/(?<duration>.*))?/)
		velocity = instruction[:velocity].to_i
		duration = instruction[:duration].to_f
		case instruction[:type]
		when BEHAVIOR_SFX
			Thread.new { play(name) }
		when BEHAVIOR_LEFT
			ROOMBA.spin_left(velocity)
		when BEHAVIOR_RIGHT
			ROOMBA.spin_right(velocity)
		when BEHAVIOR_FORWARD
			ROOMBA.straight(velocity)
		when BEHAVIOR_BACKWARD
			ROOMBA.straight(-velocity)
		when BEHAVIOR_HALT
			ROOMBA.halt
		end
		sleep (duration.to_f / 1000) if duration && duration > 0
	end
end

# routes

namespace "/command" do
	post "/direct_control" do
		vector = request.body.read.to_s.split(",").map(&:to_f)
		vel = vector[0]
		ang = vector[1]
		left = convert_ang_to_left_wheel(ang, vel)
		right = convert_ang_to_left_wheel(ang - (Math::PI * 0.5), vel)
		command_in_full_mode { ROOMBA.drive_direct(left, right) }
	end

	post "/halt" do
		command_in_full_mode {
			ROOMBA.halt
			ROOMBA.stop_all_motors
		}
	end

	post "/anchor" do
		command {
			if docked?
				ROOMBA.full_mode
				play_behavior("undock")
			else
				ROOMBA.start
				ROOMBA.dock
			end
		}
	end

	post "/songs/wrecking_ball" do
		command_in_full_mode {
			ROOMBA.define_song(3, [[70, 1], [70, 1], [70, 1], [70, 1], [70, 1], [70, 3], [69, 1] ,[69, 7], [65, 1], [70, 1], [69, 1], [67, 1], [65, 1], [70, 3], [69, 1], [69, 4]], 16)
			ROOMBA.play_song(3)
		}
	end

	post "/songs/work" do
		command_in_full_mode {
			ROOMBA.define_song(2, [[76, 2], [72, 2], [72, 2], [74, 2], [74, 4], [77, 1], [79, 1], [77, 1], [76, 1], [76, 2], [72, 2], [72, 2], [74, 2], [74, 4]], 10)
			ROOMBA.play_song(2)
		}
	end

	post "/songs/hemal" do
		command_in_full_mode {
			ROOMBA.define_song(1, [[79, 1], [74, 3], [81, 4], [72, 6], [72, 2], [84, 4], [81, 4], [79, 4], [77, 4]], 12)
			ROOMBA.play_song(1)
		}
	end

	post "/sensors" do
		command_with_return_val {
			STATE[:sensors].to_json
		}
	end

	post "/sound" do
		sound = request.body.read.to_s
		play_behavior(sound)
		"ok"
	end
end

if ROOMBA
	Thread.new do
		loop do
			sleep SENSORS_INTERVAL
			STATE[:sensors] = ROOMBA.get_sensors(6)
			docked = STATE[:docked] = STATE[:sensors][:charging_sources_available][:home_base]
		end
	end

	Thread.new do
		loop do
			sleep LIFT_CHECK_INTERVAL
			lift_check
		end
	end

	Thread.new do
		loop do
			sleep DOCK_CHECK_INTERVAL
			ROOMBA.start if docked?
		end
	end
end
