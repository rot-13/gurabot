require('index.less')

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
	sendCommand($(this).data('cmd-id'))
}

function setBattery(val) {
	$('.battery').removeClass('fa-battery-4 fa-battery-3 fa-battery-2 fa-battery-1 fa-battery-0')
	let classVal = Math.round(val * 4)
	$('.battery').addClass(`fa-battery-${classVal}`)
}

$('.btn-command').click(sendCommandHandler)
$('.text-to-speech button').click((e) => {
	e.preventDefault()
	sendCommand('speech', $('.text-to-speech input').val())
})

$('button[data-snd=true]').click(() => {
	$('button[data-snd=true]').addClass('disabled')
	setTimeout(() => {
		$('button[data-snd=true]').removeClass('disabled')
	}, 2000)
})

setBattery(1) // TODO: fetch periodically.
