require('index.scss')

const $ = require('jquery')

function sendCommand(type, data) {
	$.post(`/command/${type}`, data).fail(() => { alert('whoops, something went wrong') })
}

function sendCommandHandler() {
	sendCommand(this.id)
}

$('#move_forward').click(sendCommandHandler)
$('#move_backward').click(sendCommandHandler)
