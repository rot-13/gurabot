module RoombaApi

	SLOW_VELOCITY = 100
	MED_VELOCITY = 200

	VELOCITY = SLOW_VELOCITY

	MODES = {
		passive: 1,
		full: 2,
		safe: 3
	}

	def forward(roomba)
		command(roomba) do
			roomba.straight(SLOW_VELOCITY)
		end
	end

	def backward(roomba)
		command(roomba) do
			roomba.straight(-SLOW_VELOCITY)
		end
	end

	def left(roomba)
		command(roomba) do
			roomba.spin_left(SLOW_VELOCITY)
		end
	end

	def right(roomba)
		command(roomba) do
			roomba.spin_right(SLOW_VELOCITY)
		end
	end

	def halt(roomba)
		command(roomba) do
			roomba.halt
		end
	end

	def dock(roomba)
		command(roomba) do
			roomba.halt
		end
	end

	def clean(roomba)
		command(roomba) do
			roomba.halt
		end
	end

	def shutdown(roomba)
		command(roomba) do
			roomba.power_off # TODO: check this.
		end
	end

	######################

	def command(roomba)
		return unless roomba

		if get_mode != MODES[:full]
			roomba.full_mode
		end
		yield
		# start sets the roomba to passive mode
		# roomba.star	t
	end

	def get_mode(roomba)
		return MODES[:passive]
	end

end
