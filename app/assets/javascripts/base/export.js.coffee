handle_export_click = ->
	button = $(this)
	unless button.is('.loading')
		button.display_loading_message()
		page = button.closest('.page')
		wrapper = page.children('.wrapper')
		url = [page.attr('data-path'), 'export'].join('/')
		
		visible_inputs = wrapper.find('.table a span input:visible')
		unless input_data = visible_inputs.serialize()
			visible_inputs.prop('checked', true)
			input_data = visible_inputs.serialize()
			visible_inputs.prop('checked', false)
		data = [$.param(csrf_param()), input_data].join('&')
		
		$.post url, data, (data) ->
			button.hide_loading_message()
			data = $(data)
			data.css(marginTop: "-#{$('#container').height()}px")
			$(data).prependTo(page).trigger('loaded').animate {
				marginTop: 0 }, MEDIUM_DURATION

$ ->
	
	# Handle print button clicks.
	$('#container').delegate 'a.export', 'click.export', handle_export_click