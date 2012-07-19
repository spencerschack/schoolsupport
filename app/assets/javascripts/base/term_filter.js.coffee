prepare_term_filter = ->
	page = $(this).closest('.page')
	wrapper = page.find('.wrapper')
	scroller = page.find('.scroller')
	table = scroller.find('.table')
	buttons = wrapper.find('.title a')
	loading_message = $('<div class="loading_message">Loading</div>')
	
	$(this).delegate '.term_filter select', 'change.term_filter', ->
		buttons.fadeTo(TINY_DURATION, 0.5).on 'click.term_disable', (event) ->
			event.stopImmediatePropagation()
			event.preventDefault()
		wrapper.append(loading_message)
		
		$(this).siblings('span').text($(this).val())
		scroller.stop(true, true).animate { top: "-#{$('#container').height()}px" },
			SHORT_DURATION
		
		$.get page.attr('data-path'), { term: $(this).val() }, (data) ->
			table = $(data).find('.table')
			buttons.fadeTo(TINY_DURATION, 1).off('click.term_disable')
			loading_message.remove()
			select_path(page)
			selected = table.find('.selected')
			if selected.length
				scroller.scrollTo(selected)
			
			scroller.html(table).stop(true, true).animate { top: '75px' }, MEDIUM_DURATION
			page.find('.wrapper').trigger('loaded')
			update_count(table)

$ ->
	$('#container').delegate '.index.wrapper', 'loaded.term_filter', prepare_term_filter