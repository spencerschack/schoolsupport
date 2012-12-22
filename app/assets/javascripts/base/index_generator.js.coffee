generate_rows = ->
  table = $(this).find('.table')
  for row in rowData
    $(rowGenerator(row)).appendTo(table)
  return true

$ ->
  
  $('#container').delegate '.students.wrapper.index', 'loaded.generate_rows', generate_rows