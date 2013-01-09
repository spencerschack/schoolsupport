handle_input_blur = (event) ->
  event.preventDefault()
  event.stopImmediatePropagation()
  form = $(this).closest('form')
  inputs = $(this).closest('.note, .intervention')
  inputs = inputs.add(form.find('div:first')) # The first div holds csrf token and _method
  inputs = inputs.find(':input')
  $.post form.attr('action'), inputs.serialize()

$ ->
  $('#container').delegate '.wrapper.students .notes textarea, .wrapper.students .interventions input', 'blur.blur_submit', handle_input_blur