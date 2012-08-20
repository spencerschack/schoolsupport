handle_destroy_score_click = (event) ->
	event.preventDefault()
	self = $(this)
	destroy_confirm.apply(this, [(data) ->
		if data.success
			update_test_score_index.apply(self.closest('.wrapper'))
			
			score = self.closest('.score')
			group = score.closest('.group')
			
			if group.find('.score').length < 2
				if group.siblings('.group').length
					group.slideUp TINY_DURATION, -> $(this).remove()
				else
					destroy_page(group.closest('.page'))
			else
				score.slideUp TINY_DURATION, -> $(this).remove()
	])

update_test_score_index = ->
	index = $(this).closest('.page').next('.page')
	data = test_model_ids: $(this).find('div.table div span.parent').map(->
		$(this).attr('[data-id]')).get()
	load_test_score_view(index, data)

$ ->
	$('#container').delegate '.wrapper.test_scores .right_column .destroy',
		'click.destroy_test_score', handle_destroy_score_click
	
	$('#container').delegate '.wrapper.test_scores.create, .wrapper.test_scores.update',
		'loaded.update_index', update_test_score_index