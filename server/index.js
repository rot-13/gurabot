const koa = require('koa')
const route = require('koa-route')
const serve = require('koa-static')
const webpack = require('webpack')

const PORT = 4567
const app = koa()

if (process.env !== 'PRODUCTION') {
	const webpackMiddleware = require('koa-webpack-dev-middleware')
	const config = require('../webpack.config')
	config.bail = false
	app.use(webpackMiddleware(webpack(config)))
}

app.use(serve('./public'))

app.listen(PORT)
console.log(`GuraBot listening on port ${PORT}`);

// app.use(serve);

// TODO: KOA
// TODO: PM2 deployment (set NODE_ENV=production)
// TODO: serviceworkers caching
// TODO: webpack middleware
// TODO: webpack html for caching + hash
// TODO: roomba lib
// TODO: serve statis assets
// TODO: play text to speech with a node lib (say.js)
// TODO: play sounds with a node lib (play.js) (check if you can play multiple?)
