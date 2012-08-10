handle_import_click = ->
	button = $(this)
	unless button.is('.loading')
		button.display_loading_message()
		page = button.closest('.page')
		wrapper = page.children('.wrapper')
		url = [page.attr('data-path'), 'import'].join('/')
		
		visible_inputs = wrapper.find('div.table a span input:visible')
		data = [$.param(csrf_param()), visible_inputs.serialize()].join('&')
		
		$.post url, data, (data) ->
			button.hide_loading_message()
			data = $(data)
			data.css(marginTop: "-#{$('#container').height()}px")
			$(data).prependTo(page).trigger('loaded').animate {
				marginTop: 0 }, MEDIUM_DURATION

$ ->
	
	# Handle print button clicks.
	$('#container').delegate 'a.import', 'click.import', handle_import_click