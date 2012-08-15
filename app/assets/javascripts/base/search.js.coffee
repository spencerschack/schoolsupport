# Handle search button click.
handle_search_click = (event) ->
	self = $(this)
	wrapper = self.closest('.wrapper')
	table = wrapper.find('div.table')
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
					load_results(wrapper, value)
			), 500
		).bind 'blur.unsearch', ->
			unless $(this).val()
				load_results(wrapper)
				$(this).siblings('.clear').fadeOut TINY_DURATION, ->
					$(this).remove()
				$(this).animate { width: width, opacity: 0 }, TINY_DURATION, ->
					$(this).after(self)
					$(this).remove()

handle_term_filter_change = ->
	selected_text = $(this).find("option[value='#{$(this).val()}']").text()
	$(this).siblings('span').text(selected_text)
	load_results($(this).closest('.wrapper').find('div.table'))

load_results = (wrapper, search) ->
	url = wrapper.closest('.page').attr('data-path')
	data = { search: search } if search
	load_content wrapper, data, url, (data) ->
		table = wrapper.find('div.table')
		scroller = wrapper.find('div.scroller')
		scroller.replaceWith($(data).find('div.scroller'))
		update_select_all(table)
		
		select_path(wrapper.closest('.page'))
		selected = table.find('.selected')
		scroller.scrollTo(selected) if selected.length
		wrapper.trigger('loaded')
		update_count(table)

$ ->

	# Handle search button clicks.
	$('#container').delegate 'a.search', 'click.search', handle_search_click
	
	# Prepare term filter.
	$('#container').delegate '.term_filter select', 'change.term_filter', handle_term_filter_change