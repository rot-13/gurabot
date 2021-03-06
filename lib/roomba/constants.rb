class Roomba
	module Constants
		# These opcodes require no arguments
		OPCODES = {
			start:        128,
			control:      130,
			power:        133,
			spot:         134,
			clean:        135,
			max:          136,
			dock:         143,
			play_script:  153,
			show_script:  154
		}

		OPCODES.each do |name, val|
			send :define_method, name do
				write_chars([val])
			end
		end

		SAFE_MODE = 131
		FULL_MODE = 132

		# These opcodes require arguments
		DRIVE         = 137
		MOTORS        = 138
		LEDS          = 139
		SONG          = 140
		PLAY_SONG     = 141
		SENSORS       = 142
		DRIVE_DIRECT  = 145
		STREAM        = 148
		QUERY_LIST    = 149
		PAUSE_STREAM  = 150
		RESUME_STREAM = 150
		WAIT_DISTANCE = 156
		WAIT_ANGLE    = 157
		WAIT_EVENT    = 158

		NOTES = {
			'A'  => 69, 'A#' => 70, 'B' => 71, 'C'  => 72, 'C#' => 73, 'D'  => 74,
			'D#' => 75, 'E'  => 76, 'F' => 77, 'F#' => 78, 'G'  => 79, 'G#' => 80,
			nil => 0
		}

		MOTORS_MASK_SIDE_BRUSH = 0x1
		MOTORS_MASK_VACUUM     = 0x2
		MOTORS_MASK_MAIN_BRUSH = 0x4
	end
end
