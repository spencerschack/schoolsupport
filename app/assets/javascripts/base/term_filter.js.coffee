prepare_term_filter = ->
	term_filter = $(this).find('.term_filter')
	term_select = term_filter.find('select')
	term_label = term_filter.find('span')
	buttons = term_filter.closest('h2').siblings('a')
	page = term_filter.closest('.page')
	scroller = page.find('.scroller')
	
	term_select.change ->
		buttons.fadeTo(TINY_DURATION, 0.5).on 'click.term_disable', (event) ->
			event.stopImmediatePropagation()
			event.preventDefault()
		term_label.text(term_select.val())
		scroller.stop(true, true).animate { top: "-#{$('#container').height()}px" },
			SHORT_DURATION
		
		$.get page.attr('data-path'), { term: term_select.val() }, (data) ->
			table = $(data).find('.table')
			buttons.fadeTo(TINY_DURATION, 1).off('click.term_disable')
			
			scroller.html(table).stop(true, true).animate { top: '75px' }, MEDIUM_DURATION
			select_path(page)
			update_count(scroller.find('.table'))
			scroller.find('.index').scrollTo('.selected')

$ ->
	$('#container').delegate '.index.wrapper', 'loaded.term_filter', prepare_term_filter