// METHODS ///////////////////////////////////

/*
 * Send post command to Roomba
 * @param type - Type of command (/<type> route).
 * @param data - Additional JSON data.
 */
function sendCommand(type, data) {
	$.post('/command/' + type, data)
		.fail(function() { alert('whoops, something went wrong') })
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
$('body').on('mouseup touchend', function(e) {
	if (window.moving || window.movingDirectly) {
		window.moving = false
		window.movingDirectly = false
		sendCommand('halt')
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

// Registers the enable/disable camera button.
$('.btn-camera').click(function() {
	if ($('.btn-camera').hasClass('btn-success')) {
		$('.btn-camera').removeClass('btn-success').addClass('btn-danger')
	} else {
		$('.btn-camera').removeClass('btn-danger').addClass('btn-success')
	}
})

// Registers the enable/disable clean button.
$('.btn-clean').click(function() {
	if ($('.btn-clean').hasClass('btn-primary')) {
		$('.btn-clean').removeClass('btn-primary').addClass('btn-danger')
		$('.btn-clean i').addClass('fa-hand-paper-o').removeClass('fa-eye')
		$('.btn-clean span').text(' Halt')

	} else {
		$('.btn-clean').removeClass('btn-danger').addClass('btn-primary')
		$('.btn-clean i').addClass('fa-eye').removeClass('fa-hand-paper-o')
		$('.btn-clean span').text(' Random')
	}
})

// Joystick
function throttle(fn, threshhold, scope) {
  threshhold || (threshhold = 250);
  var last,
      deferTimer;
  return function () {
    var context = scope || this;

    var now = +new Date,
        args = arguments;
    if (last && now < last + threshhold) {
      // hold on to it
      clearTimeout(deferTimer);
      deferTimer = setTimeout(function () {
        last = now;
        fn.apply(context, args);
      }, threshhold);
    } else {
      last = now;
      fn.apply(context, args);
    }
  };
}

var joystickSize = 250
function handleDirectDrive(event) {
	x = (event.offsetX / (joystickSize / 2)) - 1
	y = (event.offsetY / (joystickSize / 2)) - 1
	window.requestAnimationFrame(function() {
		$('.joystick').css({
			left: 100 * (event.offsetX / joystickSize) + '%',
			top: 100 * (event.offsetY / joystickSize) + '%',
		})
	})
	throttledSend(x, y)
}

function sendDirectDrive(x, y) {
	console.log(x,y)
	sendCommand('direct_control', x.toPrecision(2) + ',' + y.toPrecision(2))
}

var throttledSend = throttle(sendDirectDrive, 100)

$('.direct-control').on('mousedown touchstart', function(event) {
	window.movingDirectly = true
	handleDirectDrive(event)
})

$('.direct-control').on('mousemove touchmove', function(event) {
	if (!window.movingDirectly) return
	handleDirectDrive(event)
})

setBattery(1) // TODO: fetch periodically.
