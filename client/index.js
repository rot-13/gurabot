require('index.scss')

const $ = require('jquery')

function sendCommand(type, data) {
	$.post(`/command/${type}`, data)
		.fail(() => { alert('whoops, something went wrong') })
}

function getInfo(type, callback) {
	$.get(`/info/${type}`)
		.done(callback)
		.fail(() => { alert('whoops, something went wrong') })
}

function sendCommandHandler() {
	sendCommand(this.id)
}

function setBattery(val) {
	$('.battery').removeClass('fa-battery-4 fa-battery-3 fa-battery-2 fa-battery-1 fa-battery-0')
	let classVal = Math.round(val * 4)
	$('.battery').addClass(`fa-battery-${classVal}`)
}

$('#move_forward').click(sendCommandHandler)
$('#move_backward').click(sendCommandHandler)

setBattery(1) // TODO: fetch periodically.
