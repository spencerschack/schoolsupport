handle_add_test_column_change = ->
	select = $(this)
	page = select.closest('.page')
	table = page.find('div.table')
	return unless id = select.val()
	
	select.after('<div class="loading_message" />')
	
	selected_option = select.find("option[value='#{id}']")
	if (option_group = selected_option.parent()).find('option').length < 2
		option_group.remove()
		if (prompt = select.children()).length < 2
			prompt.text('All tests have been added.')
	else
		selected_option.remove()
	
	url = page.attr('data-path')
	year = page.find('.title h2 select').val()
	url += '?' + $.param 'test_model_ids': [id]
	url += '&' + $.param term: year if year
	
	$.getJSON url, (data) ->
		cells = $(data.headers).insertBefore(table.find('div span.add'))
		width = cells.width()
		cells.hide()
		for row in data.rows
			cells = cells.add $(row.cells).insertBefore(table.find("a[data-id='#{row.id}'] span.add")).hide()
		cells.each ->
			if $(this).is('.parent')
				$(this).css(
					display: 'table-cell'
					maxWidth: 0
					minWidth: 0
					paddingLeft: 0
					paddingRight: 0
				).animate {
					maxWidth: "#{width}px"
					paddingLeft: '10px'
					paddingRight: '10px'
				}, SHORT_DURATION, ->
					$(this).css(minWidth: '', maxWidth: '', paddingLeft: '', paddingRight: '')
		select.siblings('.loading_message').remove()

$ ->
	$('#container').delegate 'div.table div span.add select', 'change.add_test_column', handle_add_test_column_change