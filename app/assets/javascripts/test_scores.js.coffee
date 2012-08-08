handle_test_model_change = ->
	self = $(this)
	self.prop('disabled', true)
	fields = self.closest('form').find('fieldset.fields').slideUp TINY_DURATION, ->
		$(this).show().find('ol').html(
			$('<li />').html(
				$('<b />').display_loading_message()))
	
	url = fields.closest('.page').attr('data-path')
	url = url.replace(/(\/new)?$/, "/dynamic_fields/#{$(this).val()}")
	$.get url, (data) ->
		self.prop('disabled', false)
		$(data).hide().replaceAll(fields).slideDown(SHORT_DURATION)

handle_expand_click = ->
	selected_id = $(this).attr('data-id')
	table = $(this).closest('.table')
	children = table.find('span.child')
	if $(this).is('.expanded')
		$(this).removeClass('expanded')
		hide_cells.apply(children)
	else
		$(this).siblings('.expanded').removeClass('expanded')
		$(this).addClass('expanded')
		children.each ->
			if $(this).is("[data-parent-id='#{selected_id}']")
				$(this).css(
					display: 'table-cell'
					maxWidth: 0
					minWidth: 0
					paddingLeft: 0
					paddingRight: 0
				).animate {
					minWidth: '50px'
					maxWidth: '50px'
					paddingLeft: '10px'
					paddingRight: '10px'
				}, SHORT_DURATION
			else
				hide_cells.apply(this)

hide_cells = ->
	$(this).animate {
		maxWidth: 0
		minWidth: 0
		paddingLeft: 0
		paddingRight: 0
	}, TINY_DURATION, ->
		$(this).hide()

handle_view_option_click = ->
	$(this).addClass('chosen')
	$(this).siblings().removeClass('chosen')

$ ->
	$('#container').delegate '.test_scores.wrapper #test_score_test_model_id',
		'change.update_dynamic_fields', handle_test_model_change
	
	$('#container').delegate '.table div span.parent', 'click.expand_test', handle_expand_click
	
	$('#container').delegate '.title .view_options a', 'click.view_option', handle_view_option_click