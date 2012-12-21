handle_import_click = ->
	button = $(this)
	unless button.is('.loading')
		button.display_loading_message()
		page = button.closest('.page')
		wrapper = page.children('.wrapper')
		url = [page.attr('data-path'), 'import'].join('/')
		
		visible_inputs = wrapper.find('div.table a span input:visible')
		data = [$.param(csrf_param()), visible_inputs.serialize()].join('&')
		
		$.post url, data, (data) ->
			button.hide_loading_message()
			data = $(data)
			data.css(marginTop: "-#{$('#container').height()}px")
			$(data).prependTo(page).trigger('loaded').animate {
				marginTop: 0 }, MEDIUM_DURATION

handle_import_load = (event) ->
	update_jobs_tables($(this))

update_jobs_tables = (wrapper) ->
	if wrapper.find('#pending_table').length
		url = wrapper.closest('.page').attr('data-path') + '/import'
		$.get url, (data) ->
			wrapper.find('#import_status').replaceWith($(data).find('#import_status'))
			setTimeout((-> update_jobs_tables(wrapper)), 500)

$ ->
	
	# Handle print button clicks.
	$('#container').delegate 'a.import', 'click.import', handle_import_click
	
	# Handle new import screens.
	$('#container').delegate '.wrapper.import', 'loaded.refresh', handle_import_load