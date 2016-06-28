const route = require('koa-route')
const say = require('say')
const play = require('play')

const TTS_VOICE = 'Alex'

module.exports = function addRoutes(app) {
	app.use(route.post('/command/speech', function *() {
		say.speak(this.request.body.text, TTS_VOICE)
		this.body = 'ok'
	}))

	// namespace '/gura' do
	// 	[
	// 		'akol_esh',
	// 		'eich_aya_sofash',
	// 		'eifo_erez',
	// 		'eifo_matan',
	// 		'floyd',
	// 		'gartner',
	// 		'gifts_project',
	// 		'kotvim_code',
	// 		'lama_ze_po',
	// 		'ma_hamatzav',
	// 		'ma_kore_po',
	// 		'ma_ratz',
	// 		'mi_isher_et_ze',
	// 		'ole_1',
	// 		'ole_2',
	// 		'sofash_risus',
	// 		'yesh_action'
	// 	].each do |gura_sound|
	// 		post "/#{gura_sound}" do
	// 			system("aplay", File.absolute_path("./server/wavs/#{gura_sound}.wav"))
	// 			'ok'
	// 		end
	// 	end
	//
	// end
}
