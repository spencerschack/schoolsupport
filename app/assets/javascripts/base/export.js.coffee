prepare_export_click = (event) ->
	index = $(this).closest('.page').next('.page').find('.index.wrapper')
	
	$(this).find('.scroller a').click (event) ->
		inputs = index.find('div.table a span input:visible')
		
		if !inputs.filter(':checked').length
			inputs.prop('checked', true)
			input_data = inputs.serializeObject()
			inputs.prop('checked', false)

		input_data ||= inputs.serializeObject()
		data = $.extend(csrf_param(), input_data)
		push_state(this.href, data)
		
		event.stopImmediatePropagation()
		event.preventDefault()

$ ->
	
	$('#container').delegate '.export.wrapper', 'loaded.export', prepare_export_click