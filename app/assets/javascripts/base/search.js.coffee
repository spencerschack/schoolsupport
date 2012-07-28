# There should never be more than one loading message.
loading_message = $('<div class="loading_message">Loading</div>')

# Handle search button click.
handle_search_click = (event) ->
	self = $(this)
	wrapper = self.closest('.wrapper')
	table = wrapper.find('.table')
	rows = $(table).find('a')
	search_field = $('<input type="text" class="search" />')
	clear_button = $('<i class="clear"></i>')
	width = self.width() - 20
	search_container = $('<div />').addClass('search_container')
	keydown_timeout = null
	search_container.append(search_field).append(clear_button).insertAfter(self)
	self.detach()
	
	clear_button.hide().fadeIn(SHORT_DURATION)
		.bind 'click.clear', ->
			$(this).siblings('.search').val('').trigger('blur.unsearch')
	search_field.css(width: width, opacity: 0)
		.animate({ width: '150px', opacity: 1 }, SHORT_DURATION, ->
			$(this).focus()
		).bind('keydown.search', ->
			clearTimeout(keydown_timeout)
			input = $(this)
			keydown_timeout = setTimeout (->
				value = input.val()
				if value != input.data('prev_val')
					input.data('prev_val', value)
					load_results(table, value)
			), 500
		).bind 'blur.unsearch', ->
			unless $(this).val()
				load_results(table)
				$(this).siblings('.clear').fadeOut TINY_DURATION, ->
					$(this).remove()
				$(this).animate { width: width, opacity: 0 }, TINY_DURATION, ->
					$(this).after(self)
					$(this).remove()

handle_term_filter_change = ->
	$(this).siblings('span').text($(this).val())
	load_results($(this).closest('.wrapper').find('.table'))

update_export_button = (table) ->
	search_field = table.closest('.wrapper').find('.title input.search')
	export_button = search_field.parent().siblings('.export').addClass('searching')
	export_button.removeClass('searching') unless search_field.val()
	update_io_buttons(table)

load_results = (table, term) ->
	wrapper = table.closest('.wrapper')
	buttons = wrapper.find('.title a')
	
	url = wrapper.closest('.page').attr('data-path') + '?'
	url += $.param term: wrapper.find('.title h2 select').val()
	url += '&' + $.param search: term if term
	
	table.empty()
	loading_message.appendTo(wrapper.find('.scroller'))
	buttons.fadeTo(TINY_DURATION, 0.5).on 'click.term_disable', (event) ->
		event.stopImmediatePropagation()
		event.preventDefault()
	update_export_button(table)
	
	table.data('search_xhr').abort() if table.data('search_xhr')
	xhr = $.get url, (data) ->
		buttons.fadeTo(TINY_DURATION, 1).off('click.term_disable')
		loading_message.remove()
		table.html($(data).find('.table').children())
		update_select_all(table)
		
		select_path(wrapper.closest('.page'))
		selected = table.find('.selected')
		scroller.scrollTo(selected) if selected.length
		wrapper.trigger('loaded')
		update_count(table)
	table.data('search_xhr', xhr)

$ ->

	# Handle search button clicks.
	$('#container').delegate 'a.search', 'click.search', handle_search_click
	
	# Prepare term filter.
	$('#container').delegate '.term_filter select', 'change.term_filter', handle_term_filter_change