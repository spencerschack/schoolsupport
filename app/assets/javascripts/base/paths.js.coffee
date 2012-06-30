# Curry the push state method.
window.push_state = (url) ->
	History.pushState(null, null, url)

# Return url without the protocol or host.
window.url_to_path = (url) ->
	url.replace("#{location.protocol}//#{location.host}", '')

# Retrieves the initial path from the meta tag and loads that url into
# history.
window.load_initial_path = ->
	initial_path = $('head meta[name="initial_path"]').attr('content')
	push_state(initial_path)

# Return whether the path represents a file.
is_file = (path) ->
	/(\.pdf|\.otf|\.ttf)/.test(path)

# Replace the current state with the href of the link that was clicked and
# ensure that the default behavior does not occur.
handle_link_click = (event) ->
	unless is_file this.href
		push_state(this.href)
		event.preventDefault()
		return false

# When a page is clicked, not an anchor or submit button, focus that page.
handle_page_click = (event) ->
	if $(event.target).is(':not(a:urlInternal, :submit, a[href="javascript:;"])')
		push_state $(this).attr('data-path')

# Retrieve the current path, handle special cases for certain paths,
# otherwise load the path.
handle_state_change = ->
	url = History.getState().url
	path = url_to_path(url)
	switch path
		when '/login' then push_state('/')
		when '/logout' then handle_logout()
		else load_path(path)

# Find the most matching page for the given path, remove unnecessary pages,
# and create the necessary pages.
# @param {String} path the path to load.
load_path = (path) ->
	$('.page').stop(true, true)
	index = path == '/'
	parts = if index then [''] else path.split('/')
	section = parts.length
	while section--
		current = "/#{parts[1..section].join('/')}"
		page = $(".page[data-path='#{current}']")
		if page.length
			
			# Handle resource links in the navigation menu.
			if parts.length > 2 && page.is('#header')
				one_more_path = "/#{parts[1..(section + 2)].join('/')}"
				one_more_link = page.find("a:urlInternal[href$='#{one_more_path}']")
				section++ if one_more_link.length
			
			animate_container_width_to(page.width(), index)
			page.prevAll('.page').each -> destroy_page($(this))
			while ++section < parts.length
				create_page "/#{parts[1..section].join('/')}"
			select_path(page)
			break

# Removes all selected classes from elements in page and adds the class to
# links that end in path.
# @param {Sring} page
window.select_path = (page) ->
	path = page.prevAll('.page:not(.destroyed)').first().attr('data-path')
	page.find('.selected').removeClass('selected')
	page.find("a:urlInternal[href$='#{path}']").addClass('selected') if path

$ ->
	# Handle internal link clicks.
	$('#container').delegate 'a:urlInternal', 'click.link', handle_link_click
	
	# Go back when a page is clicked.
	$('#container').delegate '.page', 'click.page', handle_page_click
	
	# Handle window state changes.
	$(window).on 'statechange', handle_state_change
	
	# User is logged in.
	if $('#header #navigation').length
		load_initial_path()
	
	# User is not logged in.
	else
		load_login_form()