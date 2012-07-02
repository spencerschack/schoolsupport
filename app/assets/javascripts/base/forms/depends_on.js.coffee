prepare_depends_on = ->
	
	$('[data-depends-on]').each ->
		dependent = $(this)
		parent = dependent.closest('.choices-group, select')
		dependent_id = dependent.attr('data-depends-id')
		depends_on = dependent.attr('data-depends-on').replace('_', '-')
		independent = $("[data-#{depends_on}]").closest('select')
		independent.change ->
			if $(this).val() == dependent_id
				dependent.appendTo(parent)
			else
				dependent.detach()


$ ->

	# When the wrapper loads that may contain check boxes.
	$('body').delegate '.wrapper.edit, .wrapper.new, .wrapper.update, .wrapper.create',
		'loaded.multiple', prepare_depends_on