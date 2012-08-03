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

$ ->
	$('#container').delegate '.test_scores.wrapper #test_score_test_model_id',
		'change.update_dynamic_fields', handle_test_model_change