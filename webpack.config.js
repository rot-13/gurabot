var webpack = require('webpack');

module.exports = {
	entry: 'client/index.js',
	output: {
		path: __dirname + '/public',
		filename: 'index.js'
	},
	module: {
		loaders: [
			{ test: /\.js?$/, loader: 'babel-loader' },
			{ test: /\.less?$/, loader: 'style-loader!css-loader!less-loader' },
			{ test: /\.woff(2)?(\?v=[0-9]\.[0-9]\.[0-9])?$/, loader: 'url-loader?limit=10000&minetype=application/font-woff' },
      { test: /\.(ttf|eot|svg)(\?v=[0-9]\.[0-9]\.[0-9])?$/, loader: 'file-loader' }
		]
	},
	plugins: [
		new webpack.NoErrorsPlugin()
	],
	stats: {
		colors: true
	},
	resolve: {
		modulesDirectories: ['.', 'src', 'node_modules'],
		extensions: ['', '.js']
	}
}
