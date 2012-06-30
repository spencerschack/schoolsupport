handle_print_click = ->
	wrapper = $(this).closest('.wrapper')
	if wrapper.is('.index')
		inputs = $(this).closest('.wrapper').find('input[name]')
		data = inputs.serializeArray()
	else
		data = [{
			name: $(this).attr('name'),
			value: $(this).attr('value')
		}]
	
	if data.length
		
		data.push {
			name: $('head meta[name=csrf-param]').attr('content'),
			value: $('head meta[name=csrf-token]').attr('content')
		}
		
		$(this).display_loading_message()
		$.post '/print_job/new', $.param(data), (data) ->
			
			$('#header').prevAll('.page').each ->
				destroy_page($(this))
				
			page = $('<div />').addClass('page').attr('data-path', '/print_job/new')
			page.html(data).css(width: '200px', marginLeft: '-200px')
			page.prependTo('#container')
			push_state('/print_job/new')
			
			width = page.children().width()
			console.log width
			page.animate { width: width, marginLeft: 0 }, {
				duration: MEDIUM_DURATION, step: ensure_visible_header }
			
			page.find('.wrapper').trigger('loaded')
			select_path($('#header'))
			animate_container_width_to(width)
	
	else
		self = $(this)
		self.text('Nothing Selected')
		setTimeout (-> self.text('Print')), 3000

$ ->
	
	# Handle print button clicks.
	$('#container').delegate 'a.print', 'click.print', handle_print_click