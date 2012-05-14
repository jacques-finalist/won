class @ActiveStopView extends Backbone.View
	
	constructor : ->
		@el = $("#stopActiveListView")
		Florence.eventbus.on("stop:active", (stops) =>
			@updateState(stops)
		)
	
	updateState:(activeStops) ->
		@el.html ''
		@render activeStops if activeStops.length > 0
	
	render: (activeStops) ->
		$.get(Florence.settings.baseUrl + "/template/activeStopTable.html", '', (template) =>
			$(@el).html(_.template(template, 
				stops:activeStops
			))
		)
