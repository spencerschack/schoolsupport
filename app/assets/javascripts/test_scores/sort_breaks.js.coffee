handle_table_sort = ->
	table = $(this)
	column = table.find('div span.sorted')
	leveled = column.attr('data-leveled') == 'true'
	hide_test_score_groups(table, leveled)
	if leveled
		index = column.index()
		current_level = null
		table.find("a span:nth-child(#{index + 1}) i").each ->
			level = $(this).attr('title')
			unless level == current_level
				current_level = level	
				group = $('<a />').html("<div>#{level}</div>")
				group.attr(class: $(this).attr('class') + ' group')
				unless table.data('leveled')
					group.hide()
				$(this).closest('a').before(group)
				unless table.data('leveled')
					group.slideDown(SHORT_DURATION)
	table.data('leveled', leveled)

window.hide_test_score_groups = (table, skip_reset) ->
	table.data('leveled', false) unless skip_reset
	groups = table.find('a.group')
	unless table.data('leveled')
		groups.slideUp TINY_DURATION, ->
			$(this).remove()
	else
		groups.remove()

$ ->
	$('#container').delegate '.test_scores .table', 'sorted.insert_breaks', handle_table_sort