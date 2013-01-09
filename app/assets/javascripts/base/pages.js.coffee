# Create a page with the given path, load the url into the page, and add the
# selected class to links that match in the previous page.
# {String} path the path to load.
# {Function} callback
window.create_page = (path, data, method = 'GET') ->
	console.log "CREATE PAGE: #{path}"
	page = $('<div />').addClass('page').attr('data-path', path)
	loading_message = $('<div />').addClass('loading_message')
	page.html loading_message.text('Loading')
	page.prependTo('#container')
	page.css(marginLeft: '-200px').animate { marginLeft: 0 }, MEDIUM_DURATION
	load_callback = ->
		page.find('.wrapper').trigger('loaded')
		select_path(page)
		width = page.children().width()
		page.stop(false, true).animate {
			width: width,
			marginLeft: 0
		}, {
			duration: MEDIUM_DURATION,
			step: ensure_visible_header
		}
		animate_container_width_to(width) unless page.index()
	if $.isPlainObject(data) && !$.isEmptyObject(data)
		page.load path, data, load_callback
	else
		page.load path, load_callback

# Animates the page out and removes once completed.
# {jQuery} page the page to destroy.
window.destroy_page = (page) ->
	page.find('.wrapper').trigger('unloaded')
	page.addClass('destroyed').animate {
		width: '200px'
		marginLeft: '-200px'
	}, {
		duration: SHORT_DURATION
		step: ensure_visible_header
		complete: ->
			$(this).remove()
	}

# Animate the container to the new width and adjust the marginRight so it
# stays centered in the window.
# @param {Integer} new_width
window.animate_container_width_to = (new_width, center = false) ->
	new_width /= 2
	new_width += 100 unless center
	container = $('#container')
	duration = if center then SHORT_DURATION else MEDIUM_DURATION
	container.stop().animate {
		marginRight: "-#{new_width}px"
	}, {
		duration: duration,
		step: ensure_visible_header
	}

header = null
# If the header is off the page, set its position to static to keep it on the
# page.
window.ensure_visible_header = ->
	header ||= $('#header')
	next = header.prev('.page')
	if next.length && next.offset().left < 200
		header.addClass('stuck')
	else
		header.removeClass('stuck')

$ ->
	# Handle window resize.
	$(window).resize ensure_visible_header
	
	# Handle window focus.
	$(window).focus ensure_visible_header