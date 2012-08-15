handle_view_option_click = ->
	$(this).siblings().removeClass('chosen')
	return if $(this).is('.chosen')
	$(this).addClass('chosen')
	
	page = $(this).closest('.page')
	wrapper = page.children('.wrapper')
	url = page.attr('data-path') + '/' + $(this).text()
	
	load_content wrapper, null, url, (data) ->
		wrapper.children('div.scroller').replaceWith($(data).find('div.scroller'))

$ ->
	$('#container').delegate '.title .view_options a', 'click.view_option', handle_view_option_click