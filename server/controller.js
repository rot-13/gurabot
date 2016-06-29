'use strict'

const route = require('koa-route')
const say = require('say')
const play = require('play')
const Roomba = require('roomba').Roomba

// CONSTS ///////////////////////////////////////////////////////////////

const MAX_RADIUS = 2000
const MAX_SPEED = 500
const TTS_VOICE = 'Alex'
const GURAS = require('./dances.json')

// ROOMBA INIT ////////////////////////////////////////////////////////

let roomba
if (process.env === 'PRODUCTION') {
	roomba = new Roomba({ sp: { path: '/dev/ttyUSB0', options: { baudrate: 115200 } } })
	roomba.once('ready', () => { roomba.send({ cmd: 'FULL' })
	})
} else {
	roomba = null
}

module.exports = function addRoutes(app) {

	/////// HELPERS /////////////////////////////////////////////////////////

	function runCommand(command, data) {
		if (!roomba) return
		roomba.send({ cmd: command, data: data })
	}

	function playSong(songNumber, notes, durationMultiplier) {
		const mappedFlattenedNotes = notes.map((note) => {
			return [note[0], note[1] * durationMultiplier]
		}).reduce((a, b) => a.concat(b), [])
		runCommand('SONG', [songNumber, notes.length].concat(mappedFlattenedNotes))
		runCommand('PLAY', [songNumber])
	}

	/////// MOVEMENT ////////////////////////////////////////////////////////

	app.use(route.post('/forward', function *() {
		runCommand('DRIVE', [300, -32768])
		this.body = 'ok'
	}))

	app.use(route.post('/backward', function *() {
		runCommand('DRIVE', [300, 32768])
		this.body = 'ok'
	}))

	app.use(route.post('/rotate_left', function *() {
		runCommand('DRIVE', [300, 1])
		this.body = 'ok'
	}))

	app.use(route.post('/rotate_right', function *() {
		runCommand('DRIVE', [300, -1])
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
		playSong(1, require('./songs/wrecking_ball.json'), 16)
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
