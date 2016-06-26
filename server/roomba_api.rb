module RoombaApi

	SLOW_VELOCITY = 100
	MED_VELOCITY = 250

	VELOCITY = MED_VELOCITY

	MODES = {
		passive: 1,
		full: 2,
		safe: 3
	}

	def forward(roomba)
		command(roomba) do
			roomba.straight(VELOCITY)
		end
	end

	def backward(roomba)
		command(roomba) do
			roomba.straight(-VELOCITY)
		end
	end

	def left(roomba)
		command(roomba) do
			roomba.spin_left(VELOCITY)
		end
	end

	def right(roomba)
		command(roomba) do
			roomba.spin_right(VELOCITY)
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

	def wrecking_ball(roomba)
		command(roomba) do
			song(roomba,3,[[70, 1],[70, 1],[70, 1],[70, 1],[70, 1],[70, 3],[69, 1],[69, 7], [65, 1], [70, 1], [69, 1], [67, 1], [65, 1], [70, 3],[69, 1],[69, 4]])
			roomba.play_song(3)
			# ser.write('\x8c\x03\x10F\x10F\x10F\x10F\x10F\x10F\x30E\x10E\x70A\x10F\x10E\x10C\x10A\x10F\x30E\x10E\x40')
		end
	end

	def battery_percentage(roomba)
		roomba.battery_percentage.to_s
	end

	def dock(roomba)
		roomba.write_chars([143])
	end


	######################

	def command(roomba)
		return unless roomba
		roomba.full_mode
		yield
		# start sets the roomba to passive mode
		# roomba.start
	end

	# A fixed version of Roomba's song function
	def song(roomba, song_number, notes)
	    raise RangeError if song_number < 0 || song_number > 15

	    notes.map! do |i|
	      note, duration = i

	      # notes can either be a string or the actual ID
	      note = Roomba::NOTES[note] if note.is_a?(String)
	      [note, duration*16]
	    end

	    roomba.write_chars([Roomba::SONG, song_number, notes.size] + notes.flatten)
	end
end
