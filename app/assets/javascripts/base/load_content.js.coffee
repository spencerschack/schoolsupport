loading_message = $('<div class="loading_message">Loading</div>')

window.load_content = (wrapper, data, url, callback) ->
	scroller = wrapper.children('div.scroller')
	buttons = wrapper.find('.title a')
	if data
		term = wrapper.find('.title h2 select').val()
		data['term'] = term if term
		data = $.param data
		url += "?#{data}" if data
	
	scroller.find('a').remove()
	loading_message.appendTo(wrapper.find('.scroller'))
	buttons.fadeTo(TINY_DURATION, 0.5).on 'click.term_disable', (event) ->
		event.stopImmediatePropagation()
		event.preventDefault()
	
	wrapper.data('load_content_xhr').abort() if wrapper.data('load_content_xhr')
	xhr = $.get url, (data) ->
		callback(data)
		buttons.fadeTo(TINY_DURATION, 1).off('click.term_disable')
		loading_message.remove()
		wrapper.trigger('loaded')
	wrapper.data('load_content_xhr', xhr)