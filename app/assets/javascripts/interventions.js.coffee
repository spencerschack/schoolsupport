handle_new_intervention_link_click = ->
  button = $(this)
  unless button.is('.loading')
    button.display_loading_message()
    page = button.closest('.page')
    wrapper = page.children('.wrapper')
    url = [page.attr('data-path'), 'new_intervention'].join('/')
    
    $.get url, (data) ->
      button.hide_loading_message()
      data = $(data)
      data.css(marginTop: "-#{$('#container').height()}px")
      $(data).prependTo(page).trigger('loaded').animate {
        marginTop: 0 }, MEDIUM_DURATION

handle_destroy_intervention_link_click = (event) ->
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
    row = button.closest('a')
    data['intervention_id'] = button.attr('data-id')
    url = button.closest('.page').attr('data-path') + '/destroy_intervention'
    $.post url, data, (data) ->
      if data == 'true'
          row.slideUp SHORT_DURATION, ->
          if row.siblings('a').length
            row.remove()
          else
            row.closest('.table').remove()
      else
        button.hide_loading_message()
  
  $('body').on 'click.unconfirm', (event) ->
    if $(event.target).is(button)
      event.preventDefault()
    else
      button.unbind('click.confirm').text('Delete')
      $('body').unbind('click.unconfirm')

$ ->
  
  $('#container').delegate '.wrapper.students .new_intervention_link', 'click.new_intervention_link', handle_new_intervention_link_click
  $('#container').delegate '.wrapper.students .destroy_intervention_link', 'click.destroy_intervention_link', handle_destroy_intervention_link_click