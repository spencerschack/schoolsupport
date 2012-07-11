# Select all check boxes.
handle_select_all_click = (event) ->
	table = $(this).closest('.table')
	table.find('[type="checkbox"]:visible').prop('checked', $(this).prop('checked'))
	update_io_buttons(table)

# Selects all check boxes in between the one clicked and the last one clicked
# if shift is being held down.
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
	update_io_buttons(table)

# Ensure the select all input represents the current state.
window.update_select_all = (table) ->
	not_checked = table.find('a input:not(:checked)').length
	table.find('div span input').prop('checked', !not_checked)

window.update_io_buttons = (table) ->
	wrapper = $(table).closest('.wrapper')
	export_button = wrapper.find('a.export')
	import_button = wrapper.find('a.import')
	if $(table).find('a span input:checked:visible').length
		export_button.text('Export Selected').addClass('selecting')
		import_button.text('Update').addClass('selecting')
	else
		export_button.removeClass('selecting')
		import_button.text('Import').removeClass('selecting')
		if export_button.hasClass('searching')
			export_button.text('Export Search')
		else
			export_button.text('Export All')

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