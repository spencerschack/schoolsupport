handle_input_blur = (event) ->
  event.preventDefault()
  event.stopImmediatePropagation()
  form = $(this).closest('form')
  $.post form.attr('action'), form.serialize()

$ ->
  
  $('#container').delegate '.wrapper.students .notes textarea, .wrapper.students .interventions input', 'blur.blur_submit', handle_input_blur