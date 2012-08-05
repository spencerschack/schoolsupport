handle_fullscreen_click = ->
	page = $(this).closest('.page')
	if page.is('.fullscreen')
		placeholder = page.next('.page')
		$(this).text('Fullscreen')
		offset = placeholder.offset()
		page.animate {
			width: placeholder.width()
			top: offset.top
			left: offset.left
			right: $(window).width() - offset.left - placeholder.width()
		}, SHORT_DURATION, ->
			placeholder.remove()
			$(this).removeClass('fullscreen').css
				top: ''
				left: ''
				right: ''
	else
		$(this).text('Exit Fullscreen')
		offset = page.offset()
		placeholder = $('<div class="page" />')
		placeholder.css
			width: page.width()
			height: page.height()
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
		}, SHORT_DURATION
			

$ ->
	$('#container').delegate 'a.fullscreen', 'click.fullscreen', handle_fullscreen_click