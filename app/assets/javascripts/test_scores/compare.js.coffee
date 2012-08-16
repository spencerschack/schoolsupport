handle_update_axes = ->
	parent = $(this).parent()
	data = {
		x_axis: parent.find('select[name="x_axis"]').val(),
		y_axis: parent.find('select[name="y_axis"]').val()
	}
	load_test_score_view($(this).closest('.page'), data)

handle_data_point_mouseenter = ->
	$(this).find('span.coordinates').stop().fadeIn(MICRO_DURATION)

handle_data_point_mouseleave = ->
	$(this).find('span.coordinates').stop().fadeOut(MICRO_DURATION)

$ ->
	$('#container').delegate '.test_scores .compare .select select', 'change.update_axes', handle_update_axes
	
	$('#container').delegate '.test_scores .compare .chart .data li', 'mouseenter.show_coordinates', handle_data_point_mouseenter
	$('#container').delegate '.test_scores .compare .chart .data li', 'mouseleave.show_coordinates', handle_data_point_mouseleave