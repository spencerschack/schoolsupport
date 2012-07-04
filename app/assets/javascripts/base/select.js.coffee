# Select all check boxes.
handle_select_all_click = (event) ->
	$(this).closest('.table').find('[type="checkbox"]:visible')
		.prop('checked', $(this).prop('checked'))

# If the check box was unchecked, uncheck the select all box.
handle_select_click = (event) ->
	table = $(this).closest('.table')
	last = table.data('last_selected')
	if table.data('shifted') && last && !$(this).is(last)
		method = if $(this).index() > last.index() then 'next' else 'prev'
		$(this).closest('a')["#{method}All"]('a').each ->
			check_box = $(this).find('input')
			check_box.prop('checked', true)
			!check_box.is(last) # Break each block.
	table.data('last_selected', $(this))
	update_select_all(table)

# Ensure the select all input represents the current state.
window.update_select_all = (table) ->
	table.find('div span input')
		.prop('checked', !table.find('a input:not(:checked)').length)

$ ->
	
	$('#container').delegate '.table div span input', 'click.select_all',
		handle_select_all_click
	
	$('#container').delegate '.wrapper.index', 'loaded.select', (event) ->
		table = $(this).find('.table')
		table.data('shifted', false)
		table.data('last_selected', null)
	
		table.delegate 'a span.select', 'click.select', (event) ->
			event.stopImmediatePropagation()
			if $(event.target).is('input')
				handle_select_click.apply(event.target, event)
			else
				event.preventDefault()
	
		$('body').on 'keydown.select', (event) ->
			table.data('shifted', true) if event.which == 16
	
		$('body').on 'keyup.select', (event) ->
			table.data('shifted', false) if event.which == 16

		$('body').delegate '.wrapper.index', 'unloaded.select', (event) ->
			$('body').off('keyup.select keydown.select')