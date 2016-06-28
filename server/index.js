const koa = require('koa')
const serve = require('koa-static')
const bodyParser = require('koa-bodyparser')
const webpack = require('webpack')

const addSoundRoutes = require('./controllers/sound')
const addRoombaRoutes = require('./controllers/roomba')

const PORT = 4567
const app = koa()

if (process.env !== 'PRODUCTION') {
	const webpackMiddleware = require('koa-webpack-dev-middleware')
	const config = require('../webpack.config')
	config.bail = false
	app.use(webpackMiddleware(webpack(config)))
}

app.use(serve('./public'))
app.use(bodyParser())
addSoundRoutes(app)
addRoombaRoutes(app)

app.listen(PORT)
console.log(`GuraBot listening on port ${PORT}`);

// TODO: webpack hide stuff in middleware
// TODO: namespace
// TODO: PM2 deployment (set NODE_ENV=production)
// TODO: roomba lib
// TODO: play text to speech with a node lib (say.js)
// TODO: play sounds with a node lib (play.js) (check if you can play multiple?)
