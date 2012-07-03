# Handle search button click.
handle_search_click = (event) ->
	self = $(this)
	table = self.closest('.wrapper').find('.table')
	search_field = $('<input type="text" class="search" />')
	clear_button = $('<i class="clear"></i>')
	width = self.width() - 20
	self.hide()
	clear_button.hide().insertAfter(self).fadeIn(SHORT_DURATION)
		.bind 'click.clear', ->
			$(this).siblings('.search').val('').trigger('blur.unsearch')
	search_field.css(width: width, opacity: 0).insertAfter(self)
		.animate({ width: '150px', opacity: 1 }, SHORT_DURATION, ->
			$(this).focus()
		).bind('keyup.search', ->
			search_table(table, $(this).val())
		).bind 'blur.unsearch', ->
			unless $(this).val()
				table.find('a').show()
				update_select_all(table)
				$(this).siblings('.clear').fadeOut TINY_DURATION, ->
					$(this).remove()
				$(this).animate { width: width, opacity: 0 }, TINY_DURATION, ->
					$(this).remove()
					self.show()

# Search the given table for the term, if a row contains the term, show it,
# if it does not contain it, hide it.
search_table = (table, term) ->
	regexp = new RegExp(term, 'i')
	$(table).find('a').each ->
		content = $(this).find('span').slice(1, -1).text()
		if regexp.test(content)
			unless $(this).find('input').prop('checked')
				$(table).find('div span input').prop('checked', false)
			$(this).show()
		else
			$(this).hide()

$ ->

	# Handle search button clicks.
	$('#container').delegate 'a.search', 'click.search', handle_search_click