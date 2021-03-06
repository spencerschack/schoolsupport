handle_test_score_index_loaded = ->
  touched = {}
  levels = { beg: true, fbb: true, ei: true, bbasic: true, int: true, basic: true, ea: true, prof: true, adv: true, unknown: true }
  $(this).find('.level_breaker').each ->
    classes = $(this).attr('class').split(' ')
    for klass in classes
      if levels[klass]
        if touched[klass]
          $(this).remove()
        else
          touched[klass] = true

$ ->
  
  $('#container').delegate '.wrapper.test_scores.index .table', 'infiniscrolled.ensure_single_level_breaker', handle_test_score_index_loaded