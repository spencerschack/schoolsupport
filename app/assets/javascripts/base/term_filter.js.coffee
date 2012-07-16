prepare_term_filter = ->
	term_filter = $(this).find('.term_filter')
	term_select = term_filter.find('select')
	term_label = term_filter.find('span')
	term_select.change ->
		term_label.text(term_select.val())

$ ->
	$('#container').delegate '.index.wrapper', 'loaded.term_filter', prepare_term_filter