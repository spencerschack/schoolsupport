# Display a loading message on the create or update and submit buttons. Post
# the data, if the form failed, display the new form with the errors. If the
# form succeeded, update the index and scroll the form up to reveal the show
# wrapper. If the type was create, update the url and wrapper data-path.
handle_form_submit = (event) ->
	form = $(this)
	return if form.attr('target') == '_blank'
	
	wrapper = form.closest('.wrapper')
	if wrapper.is('.edit, .update')
		message = 'Saving'
	else if wrapper.is('.import')
		message = 'Uploading'
	else if wrapper.is('.export')
		message = 'Exporting'
	else
		message = 'Creating'
		
	wrapper.find('a.create, a.update').display_loading_message(message)
	form.find(':submit').display_loading_message(message)
	form.find('.inline-errors, .errors').slideUp(SHORT_DURATION)
	
	file_inputs = form.find(':file')
	has_file = false
	file_inputs.each ->
		has_file = true if $(this).val()
	data = if has_file then form.serializeArray() else form.serialize()
	
	$.ajax this.action,
		data: data
		type: 'POST'
		files: file_inputs
		iframe: has_file
		processData: false
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
					if data.term_filter
						term_filter = index.find('.title h2')
						prev_value = term_filter.find('select').val()
						term_filter.html(data.term_filter)
						term_filter.find('select').val(prev_value)
				
					if data.row
						if !data.terms || prev_value in data.terms
							insert_row(index.find('.table'), data.row)
							select_path(index)
							index.find('.scroller').scrollTo('.selected')
						else
							term = data.terms.sort()[data.terms.length - 1]
							term_filter.find('select').val(term).trigger('change')
				
					if data.page
						wrapper.next('.show.wrapper').trigger('unloaded').remove()
						table = $(data.page).insertAfter(wrapper).trigger('loaded').find('.table')
						wrapper.animate {
							marginTop: "-#{$('#container').height()}px" }, MEDIUM_DURATION, ->
								$(this).remove()
						
			else if data.success == false
				page = $(data.page)
				errors = page.find('.inline-errors, .errors').hide()
				page.insertBefore(wrapper).trigger('loaded')
				wrapper.trigger('unloaded').remove()
				errors.slideDown(SHORT_DURATION)
		
			else
				wrapper.find('a.create, a.update').hide_loading_message()
				form.find(':submit').hide_loading_message()

				page = $("<div class='page' data-path='#{form.attr('action')}' />")
				page.html(data).css(marginLeft: '-200px').prependTo('#container')
				push_state(form.attr('action'))
				width = page.children().width()
				page.animate { width: width, marginLeft: 0 },
					{ duration: SHORT_DURATION, step: ensure_visible_header }
				animate_container_width_to(width)
	
	event.preventDefault()
	return false
	
$ ->
	
	# Handle all form submits.
	$('#container').delegate 'form', 'submit.submit', handle_form_submit