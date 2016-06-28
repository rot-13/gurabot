const colors = require('colors')
const route = require('koa-route')
const say = require('say')
const play = require('play')
const Roomba = require('roomba').Roomba

const SUCCESSFUL_RESPONSE = { status: 200, body: 'ok' }

// let roomba
// try {
// 	roomba = new Roomba({
// 		sp: {
// 			path: '/dev/ttyUSB0',
// 			options: {
// 				baudrate: 115200
// 			}
// 		}
// 	})
// } catch (e) {
// 	console.log(colors.red(`Colud not connect to Roomba (reason: ${e})`))
// }

module.exports = function addRoutes(app) {
	app.use(route.post('/command/speech', function *() {
		// say.speak('Hello!')
		// this.body = yield SUCCESSFUL_RESPONSE
	}));
}
