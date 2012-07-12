# Reload the page.
reload_page = ->
	window.location.reload()

window.login_timeout = setTimeout(reload_page, 600000)
reset_timeout = ->
	clearTimeout(window.login_timeout)
	window.login_timeout = setTimeout(reload_page, 600000)

$ ->

	# Handle reload links.
	$('#container').delegate 'a[data-reload-link]', 'click.reload', reload_page
	
	# Handle ajax requests.
	$('#container').bind 'ajaxSend', reset_timeout