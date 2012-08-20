handle_parent_click = (mousedown_event) ->
	mousedown_event.preventDefault()
	header = $(this)
	dragged = false
	
	insert_at = table = column = cells = width = left_index = right_index =
		next_offsets = prev_offsets = left_limit = right_limit = id = null
	
	$(document).on 'mousemove.table_reorder', (mousemove_event) ->
		if dragged
			offset = mousemove_event.pageX - mousedown_event.pageX
			offset = Math.max(left_limit, Math.min(right_limit, offset))
			if offset > 0
				index = next_offsets.length
				while index--
					if mousemove_event.pageX > next_offsets[index].offset
						insert_at = next_offsets[index].right_index + 1
						cells.each ->
							i = $(this).index()
							if i > right_index && i < insert_at
								$(this).css(left: "-#{width}px")
							else
								$(this).css(left: '')
						return column.css left: offset
			else
				index = prev_offsets.length
				while index--
					if mousemove_event.pageX < prev_offsets[index].offset
						insert_at = prev_offsets[index].left_index
						cells.each ->
							i = $(this).index()
							if i < left_index && i > insert_at - 1
								$(this).css(left: "#{width}px")
							else
								$(this).css(left: '')
						return column.css left: offset
			
			insert_at = left_index
			cells.each ->
				if $(this).is(".parent[data-id='#{id}'], .child[data-parent-id='#{id}']")
					$(this).css left: offset
				else
					$(this).css left: ''
		else
			dragged = true
			table = header.closest('.table')
			id = header.attr('data-id')
			
			cells = table.find('span')
			column = cells.filter(".parent[data-id='#{id}'], .child[data-parent-id='#{id}']")
			column.css(zIndex: 1)
			width = 0
			column.each ->
				if $(this).is(':visible') && $(this).parent().is('div')
					width += $(this).outerWidth()
			
			left_index = column.first().index()
			right_index = column.last().index()
			
			last_cell = column.filter(':visible:last')
			headers = header.parent().children('.parent, .child:visible')
			header_left = header.offset().left
			left_limit = headers.first().offset().left - header_left
			right_limit = headers.last().offset().left + headers.last().outerWidth() -
				last_cell.offset().left - last_cell.outerWidth()
			
			next_offsets = header.nextAll('.parent').map(->
				i = $(this).attr('data-id')
				{
					offset: $(this).offset().left
					left_index: $(this).index()
					right_index: $(this).nextAll("[data-parent-id='#{i}']:last").index()
				}
			).get()
			prev_offsets = header.prevAll('.parent').map(->
				i = $(this).attr('data-id')
				last = $(this).nextAll("[data-parent-id='#{i}']:last")
				element = if $(this).is('.expanded') then last else $(this)
				{
					offset: element.offset().left + element.outerWidth()
					left_index: $(this).index()
					right_index: last.index()
				}
			).get()
	
	$(document).on 'mouseup.parent_click_release', ->
		$(document).off('mousemove.table_reorder mouseup.parent_click_release')
		if dragged
			cells.css(left: '', zIndex: '')
			if insert_at && (insert_at > right_index || insert_at < left_index)
				table.find('div, a').each ->
					group = $(this).find("[data-id='#{id}'], [data-parent-id='#{id}']")
					$(this).children(":nth-child(#{insert_at + 1})").before(group)
		else
			handle_expand_click.apply(header)

handle_expand_click = ->
	selected_id = $(this).attr('data-id')
	table = $(this).closest('div.table')
	children = table.find("span.child[data-parent-id='#{selected_id}']")
	if $(this).is('.expanded')
		$(this).removeClass('expanded')
		if children.filter('.sorted').length
			hide_test_score_groups(table)
		children.animate {
			maxWidth: 0
			minWidth: 0
			paddingLeft: 0
			paddingRight: 0
		}, TINY_DURATION, ->
			$(this).hide()
	else
		$(this).siblings('.expanded').removeClass('expanded')
		$(this).addClass('expanded')
		if $(this).nextAll(".child.sorted[data-parent-id='#{selected_id}']").length
			table.trigger('sorted.insert_breaks')
		children.css(
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

$ ->
	$('#container').delegate 'div.table div span.parent', 'mousedown.parent_click', handle_parent_click