handle_input_blur = (event) ->
  event.preventDefault()
  event.stopImmediatePropagation()
  form = $(this).closest('form')
  $.post form.attr('action'), form.serialize()

attach_auto_input_height = ->
  $(this).find('.interventions textarea')

$ ->
  
  $('#container').delegate '.wrapper.students .notes textarea, .wrapper.students .interventions input', 'blur.blur_submit', handle_input_blur
  
  $('#container').delegate '.wrapper.students.test_scores', 'loaded.attach_auto_input_height', attach_auto_input_height