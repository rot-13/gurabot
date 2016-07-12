// METHODS ///////////////////////////////////

/*
 * Send post command to Roomba
 * @param type - Type of command (/<type> route).
 * @param data - Additional JSON data.
 */
function sendCommand(type, data, callback) {
	$.post('/command/' + type, data, function(result) {
		if (callback) { callback(null, result) }
	}).fail(function() {
		if (callback) { callback("server error") }
		alert('whoops, something went wrong')
	})
}


/*
 * Sets battery status in the UI
 * @param val - The normalized battery value (0..1)
 */
function setBattery(val) {
	$('.battery').removeClass('fa-battery-4 fa-battery-3 fa-battery-2 fa-battery-1 fa-battery-0')
	var classVal = Math.round(val * 4)
	$('.battery').addClass('fa-battery-' + classVal)
}

/*
 * Returns a throttled function call.
 * @param fn - The function to throttle.
 * @param threshold - How many times per threshold it can be called.
 */
function throttle(fn, threshhold) {
	var last, deferTimer
	return function() {
		var now = +new Date(),
		args = arguments
		if (last && now < last + threshhold) {
			clearTimeout(deferTimer)
			deferTimer = setTimeout(function() {
				last = now
				fn.apply(this, args)
			}, threshhold)
		} else {
			last = now
			fn.apply(this, args)
		}
	}
}

// PERIODIC DATA ////////////////////////////////////

// TODO: fetch periodically.
sendCommand('sensors', null, function(error, result) {
	try {
		resultJson = JSON.parse(result)
		setBattery(resultJson['battery_charge'] / resultJson['battery_capacity'])
	} catch (e) { /* do nothing */ }
})

// EVENT HANDLERS ///////////////////////////////////

// Registers all `.btn-command` buttons to send their command to the server
$('.btn-command').click(function() {
	sendCommand($(this).data('cmd-id'))
})

// Registers all `.btn-snd` buttons to send their command to the server
$('.btn-snd').click(function() {
	sendCommand('sound', $(this).data('snd-id'))
})

// Registers all `.btn-move-command` buttons to send their command to the server
// and set the `moving` flag to true.
$('.btn-move-command').on('mousedown touchstart', function() {
	window.moving = true
	sendCommand($(this).data('move-cmd-id'))
})

// Registers all mouseup events to trigger a halt command if the `moving` flag is true`
$('body').on('mouseup touchend', function(e) {
	if (window.moving || window.movingDirectly) {
		window.moving = false
		window.movingDirectly = false
		setJoystickPosition(0, 0)
		setTimeout(function() {
			sendCommand('halt')
		}, 100)
	}
})

// Registers the text-to-speech event handler.
$('.text-to-speech button').click(function(e) {
	e.preventDefault()
	sendCommand('speech', $('.text-to-speech input').val())
})

// Handle disabling text-to-speect button when there's no text
$('.text-to-speech input').keyup(function() {
	var input = $('.text-to-speech input').val()
	if (input.length == 0) {
		$('.text-to-speech button').addClass('disabled')
	} else {
		$('.text-to-speech button').removeClass('disabled')
	}
})

// DIRECT CONTROL ///////////////////////////////////

var controlSize = $('.direct-control').width()
function handleDirectDrive(event) {
	var offsetX, offsetY
	var controlOffset = $('.direct-control').offset()
	if (event.offsetX != null && event.offsetY != null) {
		offsetX = event.pageX
		offsetY = event.pageY
	} else {
		offsetX = event.targetTouches[0].pageX
		offsetY = event.targetTouches[0].pageY
	}
	offsetX -= controlOffset.left
	offsetY -= controlOffset.top

	var normalizedOffsetX = (offsetX / (controlSize * 0.5)) - 1
	var normalizedOffsetY = 1 - (offsetY / (controlSize * 0.5))
	var angle = Math.atan2(normalizedOffsetY, normalizedOffsetX)
	var maxX = Math.abs(Math.cos(angle))
	var maxY = Math.abs(Math.sin(angle))
	normalizedOffsetX = Math.min(maxX, Math.max(-maxX, normalizedOffsetX))
	normalizedOffsetY = Math.min(maxY, Math.max(-maxY, normalizedOffsetY))
	var velocity = Math.sqrt((normalizedOffsetX * normalizedOffsetX) + (normalizedOffsetY * normalizedOffsetY))

	setJoystickPosition(normalizedOffsetX, normalizedOffsetY)
	throttledSendDirectDrive(velocity, (Math.PI / 2) - angle)
}

function setJoystickPosition(x, y) {
	x = (x + 1) / 2
	y = 1 - ((y + 1) / 2)
	window.requestAnimationFrame(function() {
		$('.joystick').css({left: 100 * x + '%', top: 100 * y + '%'})
	})
}

function sendDirectDrive(vel, ang) {
	ang = ang < 0 ? (2 * Math.PI) + ang : ang
	sendCommand('direct_control', vel.toPrecision(3) + ',' + ang.toPrecision(3))
}

var throttledSendDirectDrive = throttle(sendDirectDrive, 100)

$('.direct-control').on('mousedown touchstart', function(event) {
	event.preventDefault()
	window.movingDirectly = true
	handleDirectDrive(event)
})

$('body').on('mousemove touchmove', function(event) {
	if (!window.movingDirectly) return
	event.preventDefault()
	handleDirectDrive(event)
})
