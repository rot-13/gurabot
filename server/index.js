'use strict'

const koa = require('koa')
const serve = require('koa-static')
const bodyParser = require('koa-bodyparser')
const webpack = require('webpack')

const addRoutes = require('./controller')

const PORT = 4567
const app = koa()

if (process.env.NODE_ENV !== 'production') {
	const webpackMiddleware = require('koa-webpack-dev-middleware')
	const config = require('../webpack.config')
	config.bail = false
	app.use(webpackMiddleware(webpack(config)))
}

app.use(serve('./public'))
app.use(bodyParser())
addRoutes(app)

app.listen(PORT)
console.log(`GuraBot listening on port ${PORT}`);

// TODO: PM2 deployment (set NODE_ENV=production, npm install --no-optional)

// TODO: check movement
// TODO: check wrecking ball
// TODO: check TTS (festival)
// TODO: check play sounds
