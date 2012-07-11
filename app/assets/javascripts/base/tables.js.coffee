# Sorts the given table.
# @param {jQuery} table.
sort = (table) ->
	table = $(table)
	index = parseInt(table.attr('data-sorted-at')) || 1
	data = parse_table(table)
	data.sort(comparator(index))
	table.find('a').remove()
	data.reverse() if table.attr('data-sorted-reverse') == 'true'
	for row in data
		table.append(row[0])

# Handle table header clicks.
handle_table_header_click = (event) ->
	index = $(this).index() + 1
	table = $(this).closest('.table')
	$(this).siblings().removeClass('sorted reverse')
	if $(this).is('.sorted')
		$(this).toggleClass('reverse')
	else
		$(this).addClass('sorted')
	table.attr('data-sorted-at': index)
	table.attr('data-sorted-reverse': $(this).hasClass('reverse'))
	sort(table)

# If the table is sorted, insert the row in the correct position, otherwise
# just append it.
# @param {jQuery} table
# @param {String} row
window.insert_row = (table, row) ->
	table = $(table)
	row = $(row)
	id = row.attr('data-id')
	same_id = table.find("a[data-id='#{id}']")
	if same_id.length
		same_id.html(row.html())
	else
		table.append(row)
	sort(table)
	update_count(table)
	table.find('input.search').trigger('keyup.search')

# Update the count of rows in the previous page.
window.update_count = (table) ->
	table = $(table)
	count = table.children('a').length
	page = $(table).closest('.page')
	path = page.attr('data-path')
	page.next('.page').find("a:urlInternal[href$='#{path}']")
		.find('span').text(count)

# Find the row with data-id=id and remove it from the table.
# @param {jQuery} table
# @param {String} id
window.remove_row = (table, id) ->
	$(table).find("a[data-id='#{id}']").slideUp MEDIUM_DURATION, ->
		$(this).remove()
		update_count(table)

# Parse the given table.
# @param {jQuery} table
parse_table = (table) ->
	rows = $(table).find('a')
	array = new Array(rows.length)
	rows.each (row) ->
		columns = $(this).find('span').slice(0, -1)
		array[row] = new Array(columns.length + 1)
		columns.each (column) ->
			array[row][column + 1] = $(this).text()
		array[row][1] = $(this).attr('data-id')
		array[row][0] = this
	array

# Creates a comparison function for the given index.
comparator = (index) ->
	window.c = (a, b) ->
		a = a[index] || ''
		b = b[index] || ''
		a = parseFloat(a) || a.toLowerCase()
		b = parseFloat(b) || b.toLowerCase()
		if a > b then 1 else if a < b then -1 else 0

$ ->

	# Handle table header clicks.
	$('body').delegate '.table div span:not(.spacer, .select)', 'click.sort',
		handle_table_header_click