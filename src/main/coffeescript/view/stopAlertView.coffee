class @StopAlertView extends Backbone.View

	initialize: ->
		@el = $("#stopAlertView")
		@linkEvents()
		
	linkEvents : ->	
		@linkShowActiveStops()	
		@linkShowModalDialogEvent()

	linkShowActiveStops : ->
		Florence.eventbus.on("stop:active", (stops) =>
			@updateState(stops)
		)

	linkShowModalDialogEvent : ->
		Florence.eventbus.on("showModalDialog", =>
			@hideMessages()
		)

	updateState : (stops) ->
		alerts = @createStopAlerts(stops);
					
		if alerts.messages.length > 0
			@showMessages(alerts)
		else
			@hideMessages()

	hideMessages : ->
		$(@el).html('')
		$(@el).hide()

	showMessages : (alerts) ->
		$.get(Florence.settings.baseUrl + "/template/stopAlert.html", '', (template) =>
			$(@el).html( _.template(template, alerts))
			$(@el).show()
		)

	createStopAlerts : (stops) ->
		blocked = false
		messages = []
		for stop in stops
			if stop.isExpired()
				blocked = true

			if stop.isExpired()
				messages.push(@createExpiredStopMessage(stop))
			else
				messages.push(@createActiveStopMessage(stop))
				
		{messages:messages,blocked:blocked}

	createActiveStopMessage : (stop) ->
		{
			text: "Actuele opnamestop voor #{stop.get('ward').name}"
			actions: [
				@createEndAction(stop)
				@createModifyAction(stop)
			]
		}
	
	createExpiredStopMessage : (stop) ->
		{
			text: "Verlopen opnamestop voor #{stop.get('ward').name}"
			actions: [
				@createEndAction(stop)
				@createModifyAction(stop)
			]
		}
		
	createEndAction : (stop) ->
		{text: "afmelden", url:"#stop/end/"+stop.get("id")}

	createModifyAction : (stop) ->
		{text: "wijzigen", url:"#stop/modify/"+stop.get("id")}
