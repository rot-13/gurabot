require('index.scss')

const $ = require('jquery')

let x = 'test'
console.log('HAI!', x)

function sendCommand(type, data = {}) {
	$.post(`/command/${type}`, data).fail(() => { alert('whoops, something went wrong') })
}

$('.btn-move-forward').click(sendCommand.bind(this, 'move_forward'))
$('.btn-move-backward').click(sendCommand.bind(this, 'move_backward'))
