handle_input_blur = (event) ->
  event.preventDefault()
  event.stopImmediatePropagation()
  value = $(this).val().replace(/\n/g, '<br />')
  $(this).siblings('.holder').html(value)
  form = $(this).closest('form')
  $.post form.attr('action'), form.serialize()

$ ->
  
  $('#container').delegate '.wrapper.students .notes textarea, .wrapper.students .interventions textarea', 'blur.blur_submit', handle_input_blur