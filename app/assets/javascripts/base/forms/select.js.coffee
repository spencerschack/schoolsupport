# Creates a token input that replaces check boxes.
prepare_multiple = ->
	
	# Unbind the blur handler when the form gets destroyed.
	$(this).closest('.wrapper').on 'unloaded', ->
		$('body').off 'click.blur_multiple_search'
	
	# For each token input.
	$(this).find('li.token fieldset').each ->
		list = $(this).children('ol.choices-group')
		results = $(this).children('ol.results')
		hidden = $()
		
		# Clear button handler.
		$(this).find('label').on 'click.delete', (event) ->
			event.preventDefault()
			if $(event.target).is('i')
				$(this).closest('li').hide().find('input').prop('checked', false)
		
		# When first loading, hide all tokens not selected.
		$(this).find('input:not(:checked)').closest('li.choice').hide()
		
		# Store the search input.
		search_input = $(this).find('.search_field input').autoInputWidth()
		
		list.find('[data-depends-on]').each ->
			dependent = $(this)
			dependent_id = dependent.attr('data-depends-id')
			depends_on = "data-#{dependent.attr('data-depends-on').replace('_', '-')}"
			independent = $("[#{depends_on}]").closest('select')
			independent.change ->
				results.hide()
				list.removeClass('searching')
				if $(this).find(':selected').attr(depends_on) == dependent_id
					dependent.insertBefore(search_input.parent())
				else
					hidden.add(dependent.detach())
			independent.trigger('change')
		
		# Whenever a key is pressed or focused
		search_input.on 'keydown focus click', (event) ->
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
					
					list.find('li:hidden').each ->
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
								token.show().find('input').prop('checked', true)
								search_input.closest('li.search_field').before(token)
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
	$('body').delegate '.wrapper.edit, .wrapper.new, .wrapper.update, .wrapper.create, .wrapper.export',
		'loaded.multiple', prepare_multiple