# Creates a token input that replaces check boxes.
prepare_multiple = ->
	
	# Store the select input for school.
	school_select = $(this).find('[name$="[school_id]"]')
	
	# What school is selected.
	school_id = school_select.val()
	
	# Unbind the blur handler when the form gets destroyed.
	$(this).closest('.wrapper').on 'unloaded', ->
		$('body').off 'click.blur_multiple_search'
	
	# For each check box input.
	$(this).find('li.check_boxes fieldset').each ->
		list = $(this).children('ol.choices-group')
		results = $(this).children('ol.results')
		
		# Hide the choices and set the check box to false.
		hide_choices = (choices) ->
			choices.hide().find('input').prop('checked', false)
		
		# When the school select input changes, reset school_id, hide all choices
		# that are currently selected, hide the search results, and remove the
		# searching class because the input just got blurred. This is necessary
		# because the check box inputs are dependent on the school selected.
		school_select.change ->
			school_id = $(this).val()
			hide_choices list.children('li.choice')
			results.hide()
			list.removeClass('searching')
		
		# When first loading, hide all tokens not selected.
		hide_choices $(this).find('input:not(:checked)').closest('li.choice')
		
		# Clear button handler.
		$(this).find('label').on 'click.delete', (event) ->
			event.preventDefault()
			if $(event.target).is('i')
				hide_choices $(this).closest('li')
		
		# Store the search input.
		search_input = $(this).find('.search_field input').autoInputWidth()
		
		# Whenever a key is pressed or focused
		search_input.on 'keydown focus', (event) ->
			list.addClass('searching')
			
			# Handle up and down key presses.
			if event.which == 40 || event.which == 38
				method = if event.which == 40 then 'next' else 'prev'
				previous = results.find('.hover')
				previous.siblings('li').removeClass('hover')
				if previous.length
					next = previous[method]('.result')
					if next.length
						next.addClass('hover')
						previous.removeClass('hover')
						results.scrollTo(next)
				else
					results.find('li:first').addClass('hover')
			
			# Handle enter key presses when there is a hovered result.
			else if event.which == 13
				if results.find('.hover').click().length
					event.preventDefault()
			
			# Hide results when the field is tabbed away from.
			else if event.which == 9
				results.hide()
			
			# All other keys, mostly interested in content keys.
			else
				self = $(this)
				setTimeout (->
					regexp = new RegExp(self.val(), 'i')
					found = false
					results.text('').show()
					choices = if school_id
						
						# Results when there is a school select.
						list.find("li:hidden[data-school-id='#{school_id}']")
					else
					
						# Results when there is not a school select.
						list.find('li:hidden') 
					
					choices.each ->
						token = $(this)
						if regexp.test(token.text())
							found = true
							result = $('<li class="result" />').text(token.text())
							
							# Set these manually because hover is also handled by the up and
							# down keys.
							result.mouseover -> $(this).addClass('hover')
							result.mouseleave -> $(this).removeClass('hover')
							result.mousedown -> $(this).addClass('active')
							result.mouseup -> $(this).removeClass('active')

							result.appendTo(results).click (event) ->
								token.find('input').prop('checked', true)
								search_input.closest('li.search_field').before(token.show())
								search_input.val('').focus()
					
					# No results for found or were left for entering.
					unless found
						results.html($('<li class="none" />').text('None found.'))
				), 0
		
		# Whenever the token area is clicked on, make it seem like the whole thing
		# is a text input.
		list.on 'click.focus', ->
			$(this).find('.search_field input').focus()
		
		# Attach this click handler to the body to handle blur cases.
		$('body').on 'click.blur_multiple_search', (event) ->
			
			# Do not blur if the clicked element was the list itself or within the
			# list or results.
			unless list.get(0) == event.target or
				$.contains(list.get(0), event.target) or
				$.contains(results.get(0), event.target)
					results.hide()
					list.removeClass('searching')

$ ->
	
	# When the wrapper loads that may contain check boxes.
	$('body').delegate '.wrapper.edit, .wrapper.new, .wrapper.update, .wrapper.create',
		'loaded.multiple', prepare_multiple