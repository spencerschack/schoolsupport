handle_form_submit = (event) ->
	event.preventDefault()
	event.stopImmediatePropagation()
	form = $(this)
	form.find(':submit').display_loading_message()
	data = form.serialize() + '&' + $.param(csrf_param())
	$.post form.attr('action'), data, (data) ->
		if data.success
			form.find(':submit').hide_loading_message()
			if form.is('#new_intervention')
				form.closest('.interventions').find('.table').append(data.page)
			else if form.is('#new_student_note')
				form.before(data.page)
			form[0].reset()
		else
			form.replaceWith(data.page)

handle_destroy_link_click = (event) ->
  event.preventDefault()
  button = $(this)
  button.text('Are you sure?')
  button.on 'click.confirm', (event) ->
    event.stopImmediatePropagation()
    event.preventDefault()
    button.display_loading_message('Deleting')
    button.off 'click.confirm'
    $('body').off 'click.unconfirm'
    data = csrf_param()
    
    url = button.closest('.page').attr('data-path')
    if button.is('.destroy_intervention_link')
      row = button.closest('a')
      data['intervention_id'] = button.attr('data-id')
      url += '/destroy_intervention'
    else if button.is('.destroy_student_note_link')
      row = button.closest('p')
      data['student_note_id'] = button.attr('data-id')
      url += '/destroy_student_note'

    $.post url, data, (data) ->
      if data == 'true'
        row.slideUp SHORT_DURATION, ->
           row.remove()
      else
        button.hide_loading_message()
  
  $('body').on 'click.unconfirm', (event) ->
    if $(event.target).is(button)
      event.preventDefault()
    else
      button.unbind('click.confirm').text('Delete')
      $('body').unbind('click.unconfirm')

$ ->
  
  $('#container').delegate '.wrapper.students form#new_intervention, .wrapper.students form#new_student_note', 'submit.submit_form', handle_form_submit
  $('#container').delegate '.wrapper.students .destroy_intervention_link, .wrapper.students .destroy_student_note_link', 'click.destroy_link', handle_destroy_link_click