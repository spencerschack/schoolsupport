# Select all check boxes.
handle_select_all_click = (event) ->
	$(this).closest('.table').find('[type="checkbox"]')
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
update_select_all = (table) ->
	check_box = table.find('input[name="all"]')
	check_box.prop('checked', !table.find('a input:not(:checked)').length)

$ ->
	
	$('body').delegate '.table div span input', 'click.select_all',
		handle_select_all_click
	
	$('body').delegate '.wrapper.index', 'loaded.select', (event) ->
		table = $(this).find('.table')
		table.data('shifted', false)
		table.data('last_selected', null)
	
		table.find('a span.select').on 'click.select', (event) ->
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