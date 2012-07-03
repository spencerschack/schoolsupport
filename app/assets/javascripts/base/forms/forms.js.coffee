# Display a loading message on the create or update and submit buttons. Post
# the data, if the form failed, display the new form with the errors. If the
# form succeeded, update the index and scroll the form up to reveal the show
# wrapper. If the type was create, update the url and wrapper data-path.
handle_form_submit = (event) ->
	return if $(this).attr('target') == '_blank'
	
	wrapper = $(this).closest('.wrapper')
	if wrapper.is('.edit, .update')
		message = 'Saving'
	else if wrapper.is('.import')
		message = 'Uploading'
	else
		message = 'Creating'
		
	wrapper.find(":submit, a.create, a.update").display_loading_message(message)
	$(this).find('.inline-errors, .errors').slideUp(SHORT_DURATION)
	
	file_inputs = $(this).find(':file')
	has_file = false
	file_inputs.each ->
		has_file = true if $(this).val()
	data = if has_file then $(this).serializeArray() else $(this).serialize()
	
	$.ajax this.action,
		data: data,
		type: 'POST'
		files: file_inputs,
		iframe: has_file,
		processData: false,
		dataType: 'json',
		success: (data) ->
			
			if data.success
				page = wrapper.parent()
				index = page.next('.page')
				
				if data.path
					old_path = page.attr('data-path').split('/')[0..-2].join('/')
					if old_path == data.path.split('/')[0..-2].join('/')
						page.attr('data-path', data.path)
					push_state(data.path)
				
				unless index.is('.destroyed')
					if data.row
						insert_row(index.find('.table'), data.row)
						select_path(index)
					index.find('.table_container').scrollTo('.selected')
					wrapper.next('.show.wrapper').trigger('unloaded').remove()
					$(data.page).insertAfter(wrapper).trigger('loaded')
					wrapper.animate {
						marginTop: "-#{$('#container').height()}px" }, MEDIUM_DURATION, ->
							$(this).remove()
							
			else
				page = $(data.page)
				errors = page.find('.inline-errors, .errors').hide()
				page.insertBefore(wrapper).trigger('loaded')
				wrapper.trigger('unloaded').remove()
				errors.slideDown(SHORT_DURATION)
	
	event.preventDefault()
	return false
	
$ ->
	
	# Handle all form submits.
	$('#container').delegate 'form', 'submit.submit', handle_form_submit