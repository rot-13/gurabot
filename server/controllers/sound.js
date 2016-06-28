const route = require('koa-route')
const say = require('say')
const play = require('play')

const TTS_VOICE = 'Alex'

module.exports = function addRoutes(app) {
	app.use(route.post('/command/speech', function *() {
		say.speak(this.request.body.text, TTS_VOICE)
		this.body = 'ok'
	}))
}
