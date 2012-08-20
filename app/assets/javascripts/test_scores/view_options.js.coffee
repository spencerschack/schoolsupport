handle_view_option_click = ->
	$(this).siblings().removeClass('chosen')
	return if $(this).is('.chosen')
	$(this).addClass('chosen')
	load_test_score_view($(this).closest('.page'))

window.load_test_score_view = (page, data) ->
	wrapper = page.children('.wrapper')
	url = page.attr('data-path')
	url += '/compare' if page.find('.title .chosen').is('.compare')
	load_content wrapper, data, url, (data) ->
		wrapper.children('div.scroller').replaceWith($(data).find('div.scroller'))
		select_path(page)

$ ->
	$('#container').delegate '.title .view_options a', 'click.view_option', handle_view_option_click