# Handle search button click.
handle_search_click = (event) ->
	self = $(this)
	table = self.closest('.wrapper').find('.table')
	rows = $(table).find('a')
	search_field = $('<input type="text" class="search" />')
	clear_button = $('<i class="clear"></i>')
	width = self.width() - 20
	self.hide()
	search_container = $('<div />').addClass('search_container')
	search_container.append(search_field).append(clear_button).insertAfter(self)
	clear_button.hide().fadeIn(SHORT_DURATION)
		.bind 'click.clear', ->
			$(this).siblings('.search').val('').trigger('blur.unsearch')
	search_field.css(width: width, opacity: 0)
		.animate({ width: '150px', opacity: 1 }, SHORT_DURATION, ->
			$(this).focus()
		).bind('keyup.search', ->
			
			regexp = new RegExp($(this).val(), 'i')
			rows.each ->
				content = $(this).find('span').slice(1, -1).text()
				if regexp.test(content)
					unless $(this).find('input').prop('checked')
						$(table).find('div span input').prop('checked', false)
					$(this).appendTo(table)
				else
					$(this).detach()
			update_export_button($(this), table)
				
		).bind 'blur.unsearch', ->
			unless $(this).val()
				update_export_button($(this), table)
				rows.appendTo(table)
				update_select_all(table)
				$(this).siblings('.clear').fadeOut TINY_DURATION, ->
					$(this).remove()
				$(this).animate { width: width, opacity: 0 }, TINY_DURATION, ->
					$(this).remove()
					self.show()

update_export_button = (search_field, table) ->
	export_button = search_field.parent().siblings('.export').addClass('searching')
	unless search_field.val()
		export_button.removeClass('searching')
	update_io_buttons(table)

$ ->

	# Handle search button clicks.
	$('#container').delegate 'a.search', 'click.search', handle_search_click