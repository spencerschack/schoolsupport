handle_test_model_change = ->
	self = $(this)
	self.prop('disabled', true)
	fields = self.closest('form').find('fieldset.fields').slideUp TINY_DURATION, ->
		$(this).show().find('ol').html(
			$('<li />').html(
				$('<b />').display_loading_message()))
	
	url = fields.closest('.page').attr('data-path')
	url = url.replace(/(\/new)?$/, "/dynamic_fields/#{$(this).val()}")
	$.get url, (data) ->
		self.prop('disabled', false)
		$(data).hide().replaceAll(fields).slideDown(SHORT_DURATION)

handle_parent_click = (mousedown_event) ->
	mousedown_event.preventDefault()
	header = $(this)
	dragged = false
	
	insert_at = null
	
	$(document).on 'mousemove.table_reorder', (mousemove_event) ->
		if dragged
			offset = mousemove_event.pageX - mousedown_event.pageX
			offset = Math.max(left_limit, Math.min(right_limit, offset))
			if offset > 0
				index = next_offsets.length
				while index--
					if mousemove_event.pageX > next_offsets[new_index].offset
						insert_at = next_offsets[index].right_index
						table.find("span:gt(#{dragging_right_index})" +
							":lt(#{insert_at + 1})").css left: "-#{width}px"
						break
			else if offset < 0
				index = prev_offsets.length
				while index--
					if mousemove_event.pageX < prev_offsets[new_index].offset
						insert_at = prev_offsets[index].left_index
						table.find("span:gt(#{insert_at - 1})" +
							":lt(#{dragging_left_index})").css left: "-#{width}px"
						break
			cells.addClass('dragging').css
				left: offset
		else
			dragged = true
			table = header.closest('.table')
			id = header.attr('data-id')
			
			cells = table.find("div span.parent[data-id='#{id}'], div span.child[data-parent-id='#{id}']")
			width = 0
			cells.each -> width += $(this).width()
			
			last_cell = cell.filter(':visible:last')
			headers = header.parent().children('.parent, .child:visible')
			header_left = header.offset().left
			left_limit = headers.first().offset().left - header_left
			right_limit = headers.last().offset().left + headers.last().outerWidth() -
				last_cell.offset().left - last_cell.outerWidth()
			
			next_offsets = header.nextAll('.parent').map(->
				{
					offset: $(this).offset().left
					index: $(this).index()
				}
			).get()
			prev_offsets = header.prevAll('.parent').map(->
				element = if $(this).is('.expanded')
					id = $(this).attr('data-id')
					$(this).nextAll("span.child[data-parent-id='#{id}']:last")
				else
					$(this)
				{
					offset: element.offset().left + element.outerWidth()
					index: $(this).index()
				}
			).get()
	
	$(document).on 'mouseup.parent_click_release', ->
		$(document).off('mousemove.table_reorder mouseup.parent_click_release')
		if dragged
			cells.removeClass('dragging').css(left: '')#.insertAfter insert_at
		else
			handle_expand_click.apply(header)

handle_expand_click = ->
	selected_id = $(this).attr('data-id')
	table = $(this).closest('div.table')
	children = table.find('span.child')
	if $(this).is('.expanded')
		$(this).removeClass('expanded')
		hide_cells.apply(children)
	else
		$(this).siblings('.expanded').removeClass('expanded')
		$(this).addClass('expanded')
		children.each ->
			if $(this).is("[data-parent-id='#{selected_id}']")
				$(this).css(
					display: 'table-cell'
					maxWidth: 0
					minWidth: 0
					paddingLeft: 0
					paddingRight: 0
				).animate {
					minWidth: '50px'
					maxWidth: '50px'
					paddingLeft: '10px'
					paddingRight: '10px'
				}, SHORT_DURATION
			else
				hide_cells.apply(this)

hide_cells = ->
	$(this).animate {
		maxWidth: 0
		minWidth: 0
		paddingLeft: 0
		paddingRight: 0
	}, TINY_DURATION, ->
		$(this).hide()

handle_view_option_click = ->
	$(this).addClass('chosen')
	$(this).siblings().removeClass('chosen')

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
	$('#container').delegate '.test_scores.wrapper #test_score_test_model_id',
		'change.update_dynamic_fields', handle_test_model_change
	
	$('#container').delegate 'div.table div span.parent', 'mousedown.parent_click', handle_parent_click
	
	$('#container').delegate '.title .view_options a', 'click.view_option', handle_view_option_click
	
	$('#container').delegate 'div.table div span.add select', 'change.add_test_column', handle_add_test_column_change