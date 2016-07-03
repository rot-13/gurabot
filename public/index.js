// METHODS ///////////////////////////////////

/*
 * Send post command to Roomba
 * @param type - Type of command (/<type> route).
 * @param data - Additional JSON data.
 */
function sendCommand(type, data) {
	$.post(`/command/${type}`, data)
		.fail(() => { alert('whoops, something went wrong') })
}

/*
 * Sets battery status in the UI
 * @param val - The normalized battery value (0..1)
 */
function setBattery(val) {
	$('.battery').removeClass('fa-battery-4 fa-battery-3 fa-battery-2 fa-battery-1 fa-battery-0')
	let classVal = Math.round(val * 4)
	$('.battery').addClass(`fa-battery-${classVal}`)
}

// EVENT HANDLERS ///////////////////////////////////

// Registers all `.btn-command` buttons to send their command to the server
$('.btn-command').click(function() {
	sendCommand($(this).data('cmd-id'))
})

// Registers all `.btn-move-command` buttons to send their command to the server
// and set the `moving` flag to true.
$('.btn-move-command').on('mousedown touchstart', function() {
	window.moving = true
	sendCommand($(this).data('move-cmd-id'))
})

// Registers all mouseup events to trigger a halt command if the `moving` flag is true`
$('body').on('mouseup touchend', (e) => {
	if (window.moving) {
		window.moving = false
		sendCommand('halt')
	}
})

// Registers the text-to-speech event handler.
$('.text-to-speech button').click((e) => {
	e.preventDefault()
	sendCommand('speech', $('.text-to-speech input').val())
})

// Handle disabling text-to-speect button when there's no text
$('.text-to-speech input').keyup(() => {
	let input = $('.text-to-speech input').val()
	if (input.length == 0) {
		$('.text-to-speech button').addClass('disabled')
	} else {
		$('.text-to-speech button').removeClass('disabled')
	}
})

// Registers the enable/disable camera button.
$('.btn-camera').click(() => {
	if ($('.btn-camera').hasClass('btn-success')) {
		$('.btn-camera').removeClass('btn-success').addClass('btn-danger')
	} else {
		$('.btn-camera').removeClass('btn-danger').addClass('btn-success')
	}
})

setBattery(1) // TODO: fetch periodically.
