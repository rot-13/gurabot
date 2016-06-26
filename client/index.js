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

$('.btn-move-command').on('mousedown touchend', function() {
	window.moving = true
	sendCommand($(this).data('move-cmd-id'))
})

$('body').on('mouseup touchstart', () => {
	if (window.moving) {
		window.moving = false
		sendCommand('halt')
	}
})

$('.text-to-speech button').click((e) => {
	e.preventDefault()
	sendCommand('speech', $('.text-to-speech input').val())
})

$('button[data-snd=true]').click(() => {
	$('button[data-snd=true]').addClass('disabled')
	setTimeout(() => {
		$('button[data-snd=true]').removeClass('disabled')
	}, 5000)
})

$('.btn-camera').click(() => {
	if ($('.btn-camera').hasClass('btn-success')) {
		$('.btn-camera').removeClass('btn-success').addClass('btn-warning').text('Disable camera')
	} else {
		$('.btn-camera').removeClass('btn-warning').addClass('btn-success').text('Enable camera')
	}
})

setBattery(1) // TODO: fetch periodically.
