# Reload the page.
reload_page = ->
	window.location.reload()

window.login_timeout = setTimeout(reload_page, 600000)
reset_timeout = ->
	clearTimeout(window.login_timeout)
	window.login_timeout = setTimeout(reload_page, 600000)

$ ->
	
	# Handle ajax requests.
	$('#container').bind 'ajaxSend', reset_timeout