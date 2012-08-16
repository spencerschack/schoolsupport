handle_update_axes = ->
	parent = $(this).parent()
	data = {
		x_axis: parent.find('select[name="x_axis"]').val(),
		y_axis: parent.find('select[name="y_axis"]').val()
	}
	load_test_score_view($(this).closest('.page'), data)

$ ->
	$('#container').delegate '.test_scores .compare .select select', 'change.update_axes', handle_update_axes