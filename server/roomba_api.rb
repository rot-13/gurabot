module RoombaApi

	SLOW_VELOCITY = 100
	MED_VELOCITY = 200

	VELOCITY = SLOW_VELOCITY

	MODES = {
		passive: 1,
		full: 2,
		safe: 3
	}

	def move_forward(roomba)
		puts "moving forward"
		command(roomba) do
			roomba.straight(SLOW_VELOCITY)
		end
	end

	def stop(roomba)
		command(roomba) do
			roomba.halt
		end
	end

	def command(roomba)
		if get_mode != MODES[:full]
			roomba.full_mode
		end
		yield
		# start sets the roomba to passive mode
		roomba.start
	end

	def get_mode(roomba)
		return MODES[:passive]
	end

end