# If cancel is clicked on a new or create page, simply focus its parent
# page. If it is an edit page, hide the form and bring up the show wrapper.
handle_cancel_click = (event) ->
	if $(this).closest('.wrapper').is('.new, .create')
		push_state $(this).closest('.page').next('.page').attr('data-path')
	else
		$(this).closest('.wrapper.edit, .wrapper.import').trigger('unloaded')
			.animate { marginTop: "-#{$('#container').height()}px" },
				SHORT_DURATION, -> $(this).remove()

# When an edit button is clicked, display a loading message within that
# button, load the form, and animate it in to replace the show wrapper.
handle_edit_click = (event) ->
	button = $(this)
	
	unless button.is('.loading')
		button.display_loading_message()
		page = button.closest('.page')
		
		action = 'edit' if button.hasClass('edit')
		action = 'import' if button.hasClass('import')
		url = [page.attr('data-path'), action].join('/')
		
		$.get url, (data) ->
			button.hide_loading_message()
			data = $(data)
			data.css(marginTop: "-#{$('#container').height()}px")
			$(data).prependTo(page).trigger('loaded').animate {
				marginTop: 0 }, MEDIUM_DURATION

# After clicking the delete button, show a confirmation message in the
# button. After a second click, destroy the record and remove the page. If
# the user clicks somewhere else, put the button in its previous state.
handle_destroy_click = (event) ->
	self = $(this)
	self.text('Are you sure?').addClass('confirm')
	self.bind 'click.confirm', (event) ->
		event.stopImmediatePropagation()
		self.unbind('click.confirm').display_loading_message('Deleting')
		$('body').unbind('click.unconfirm')
		path = self.attr('data-path')
		index = self.closest('.page').next('.page')
		id = path.match(/(\d+)$/)[0]
		destroy_path path, ->
			push_state index.attr('data-path')
			remove_row(index.find('.table'), id)
	$('body').bind 'click.unconfirm', (event) ->
		unless $(event.target).is(self)
			self.unbind('click.confirm').removeClass('confirm').text('Delete')
			$('body').unbind('click.unconfirm')

# Generate the necessary form data to destroy a resource and post that to
# the given path and callback.
destroy_path = (path, callback = null) ->
	csrf_param = $('head meta[name=csrf-param]').attr('content')
	csrf_token = $('head meta[name=csrf-token]').attr('content')
	form_data = _method: 'delete'
	form_data[csrf_param] = csrf_token
	$.post path, form_data, ->
		callback() if $.isFunction(callback)

# Handle create and update button clicks.
handle_submit_click = (event) ->
	$(this).closest('.wrapper').find('form').submit()
	
$ ->
	
	# Handle cancel button clicks.
	$('#container').delegate 'a.cancel', 'click.cancel', handle_cancel_click
	
	# Handle edit button clicks.
	$('#container').delegate 'a.edit, a.import', 'click.edit', handle_edit_click
	
	# Handle create and update button clicks.
	$('#container').delegate 'a.update, a.create', 'click.submit',
		handle_submit_click
	
	# Handle destroy button clicks.
	$('#container').delegate 'a.destroy', 'click.destroy', handle_destroy_click