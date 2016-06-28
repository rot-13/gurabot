const route = require('koa-route')
const Roomba = require('roomba').Roomba

const ROTATE_SPEED = 250
const MAX_SPEED = 300

let roomba
if (process.env !== 'PRODUCTION') {
	roomba = new Roomba({ sp: { path: '/dev/ttyUSB0', options: { baudrate: 115200 } } })
	roomba.once('ready', () => { roomba.send({ cmd: 'FULL' })
	})
} else {
	roomba = null
}

function runCommand(command, data) {
	if (!roomba) return
	roomba.send({ cmd: command, data: data }
}

module.exports = function addRoutes(app) {
	app.use(route.post('/command/forward', function *() {
		this.body = 'ok'
	}))

	app.use(route.post('/command/backward', function *() {
		this.body = 'ok'
	}))

	app.use(route.post('/command/rotate_left', function *() {
		this.body = 'ok'
	}))

	app.use(route.post('/command/rotate_right', function *() {
		this.body = 'ok'
	}))

	app.use(route.post('/command/wake', function *() {
		runCommand('FULL')
		this.body = 'ok'
	}))

	app.use(route.post('/command/sleep', function *() {
		runCommand('START')
		this.body = 'ok'
	}))

	app.use(route.post('/command/halt', function *() {
		runCommand('DRIVE', [0, 0])
		this.body = 'ok'
	}))

	app.use(route.post('/command/dock', function *() {
		runCommand('DOCK')
		this.body = 'ok'
	}))

	app.use(route.post('/command/clean', function *() {
		runCommand('CLEAN')
		this.body = 'ok'
	}))

	app.use(route.post('/command/songs/wrecking_ball', function *() {
		// song(roomba,3,[[70, 1],[70, 1],[70, 1],[70, 1],[70, 1],[70, 3],[69, 1],[69, 7], [65, 1], [70, 1], [69, 1], [67, 1], [65, 1], [70, 3],[69, 1],[69, 4]])
		// roomba.play_song(3)
		// def song(roomba, song_number, notes)
		// 		raise RangeError if song_number < 0 || song_number > 15
		//
		// 		notes.map! do |i|
		// 			note, duration = i
		//
		// 			# notes can either be a string or the actual ID
		// 			note = Roomba::NOTES[note] if note.is_a?(String)
		// 			[note, duration*16]
		// 		end
		//
		// 		roomba.write_chars([Roomba::SONG, song_number, notes.size] + notes.flatten)
		// end
		this.body = 'ok'
	}))
}
