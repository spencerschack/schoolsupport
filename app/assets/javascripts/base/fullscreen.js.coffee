handle_fullscreen_click = ->
	page = $(this).closest('.page')
	unless page.is('.fullscreen')
		page.trigger 'enter_fullscreen'

enter_fullscreen = (event, callback) ->
	page = $(this)
	page.find('.title a.fullscreen').text('Exit Fullscreen')
	offset = page.offset()
	placeholder = $('<div class="page" />')
	placeholder.css width: page.width()
	placeholder.insertAfter(page)
	page.addClass('fullscreen').css
		width: ''
		top: offset.top
		left: offset.left
		right: $(window).width() - offset.left - placeholder.width()
	page.animate {
		top: 0
		left: 0
		right: 0
	}, SHORT_DURATION, ->
		callback() if $.isFunction(callback)
	page.find('a').on 'click.exit_fullscreen_first', (event) ->
		event.stopImmediatePropagation()
		event.preventDefault()
		self = $(this)
		page.trigger 'exit_fullscreen', ->
			self.trigger 'click'

exit_fullscreen = (event, callback) ->
	page = $(this)
	page.find('a').off 'click.exit_fullscreen_first'
	placeholder = page.next('.page')
	page.find('.title a.fullscreen').text('Fullscreen')
	offset = placeholder.offset()
	page.animate {
		width: placeholder.width()
		top: offset.top
		left: offset.left
		right: $(window).width() - offset.left - placeholder.width()
	}, SHORT_DURATION, ->
		callback() if $.isFunction(callback)
		placeholder.remove()
		$(this).removeClass('fullscreen').css
			top: ''
			left: ''
			right: ''

$ ->
	$('#container').delegate 'a.fullscreen', 'click.fullscreen', handle_fullscreen_click
	
	$('#container').delegate '.page', 'enter_fullscreen', enter_fullscreen
	$('#container').delegate '.page', 'exit_fullscreen', exit_fullscreen