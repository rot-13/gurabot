const route = require('koa-route')
const say = require('say')
const play = require('play')
const Roomba = require('roomba').Roomba

// CONSTS ///////////////////////////////////////////////////////////////

const ROTATE_SPEED = 250
const MAX_SPEED = 300
const TTS_VOICE = 'Alex'
const GURAS = {
	akol_esh:        [],
	eich_aya_sofash: [],
	eifo_erez:       [],
	eifo_matan:      [],
	floyd:           [],
	gartner:         [],
	gifts_project:   [],
	kotvim_code:     [],
	lama_ze_po:      [],
	ma_hamatzav:     [],
	ma_kore_po:      [],
	ma_ratz:         [],
	mi_isher_et_ze:  [],
	ole_1:           [],
	ole_2:           [],
	sofash_risus:    [],
	yesh_action:     []
}

// ROOMBA INIT ////////////////////////////////////////////////////////

let roomba
if (process.env === 'PRODUCTION') {
	roomba = new Roomba({ sp: { path: '/dev/ttyUSB0', options: { baudrate: 115200 } } })
	roomba.once('ready', () => { roomba.send({ cmd: 'FULL' })
	})
} else {
	roomba = null
}

function runCommand(command, data) {
	if (!roomba) return
	roomba.send({ cmd: command, data: data })
}

module.exports = function addRoutes(app) {

	/////// MOVEMENT ////////////////////////////////////////////////////////

	app.use(route.post('/forward', function *() {
		// TODO
		this.body = 'ok'
	}))

	app.use(route.post('/backward', function *() {
		// TODO
		this.body = 'ok'
	}))

	app.use(route.post('/rotate_left', function *() {
		// TODO
		this.body = 'ok'
	}))

	app.use(route.post('/rotate_right', function *() {
		// TODO
		this.body = 'ok'
	}))

	app.use(route.post('/halt', function *() {
		runCommand('DRIVE', [0, 0])
		this.body = 'ok'
	}))

	/////// PROGRAMS ////////////////////////////////////////////////////////

	app.use(route.post('/dock', function *() {
		runCommand('DOCK')
		this.body = 'ok'
	}))

	app.use(route.post('/clean', function *() {
		runCommand('CLEAN')
		this.body = 'ok'
	}))

	/////// STATES ////////////////////////////////////////////////////////

	app.use(route.post('/wake', function *() {
		runCommand('FULL')
		this.body = 'ok'
	}))

	app.use(route.post('/sleep', function *() {
		runCommand('START')
		this.body = 'ok'
	}))

	/////// SONGS ////////////////////////////////////////////////////////

	app.use(route.post('/songs/wrecking_ball', function *() {
		// TODO
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

	/////// TTS ////////////////////////////////////////////////////////

	app.use(route.post('/speech', function *() {
		say.speak(this.request.body.text, TTS_VOICE)
		this.body = 'ok'
	}))

	/////// SOUNDS AND DANCES //////////////////////////////////////////

	Object.keys(GURAS).forEach((key) => {
		app.use(route.post(`/gura/${key}`, function *() {
			play.sound(`./server/wavs/${key}.wav`)
			this.body = 'ok'
		}))
	})

}
