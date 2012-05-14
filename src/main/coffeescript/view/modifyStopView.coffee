class @ModifyStopView extends @StopView

	constructor: () ->
		super()
		@templateViewName="modifyStop.html"

	render: (template, ward) ->
		super
		
		@loadWardList()
		@addDatepicker(@getField('endDate'))
		
		@beginTime = @addTimepicker(@getField('beginTime'))
		@endTime = @addTimepicker(@getField('endTime'))
		@beginTime.val @stop.displayBeginTime()
		@endTime.val @stop.displayEndTime()
		
		if @stop.isActive()
			@getField('beginDate').attr('disabled', 'disabled')
			@getField('authority').attr('disabled', 'disabled')
			@getField('position').attr('disabled', 'disabled')
			@getField('ward').attr('disabled', 'disabled')
			@beginTime.disable()
		else
			@addDatepicker(@getField('beginDate'))
			
			if !@stop.isPlanned()
				@getField('beginDate').attr('disabled', 'disabled')
				@beginTime.disable()

	createDefaultValues: ->
		{
			beginDate: @stop.displayBeginDate()
			beginTime: @stop.displayBeginTime()
			endDate: @stop.displayEndDate()
			endTime: @stop.displayEndTime()
			description: @stop.get("description")
			authority: @stop.get("authority")
			position: @stop.get("position")
		}
	
	updateWardField: () ->
		wardField = @getField('ward')
		for ward in @wardList
			option = new Option(ward.type.name,ward.id,false,ward.id==@stop.get("ward").id)
			$(option).text ward.type.name
			wardField.append(option)

	loadWardList : ->
		$.get(Florence.settings.baseUrl + "/rest/mywards", '', (result) =>
			@wardList=result.wardList
			@updateWardField()
		)

	show : (stopId) ->
		super
		@stop=new Stop({id:stopId})
		@stop.fetch(
			error : (model,errors) ->
				console.log(errors)
			success : =>
				@renderPage()
		)

	formToModel: ->
		result = super
		$.extend(result, {type: 'planned'})
		if @stop.isActive()
			$.extend(result, {ward: '' + @stop.get('ward').id})	

		return result
	
	validate: (model) ->
		errors = {hasErrors:false}
	
		if @stop.isActive()
			@validateEnd(errors, model)
			
			if !util.time.endAfterBegin(@stop.get('begin'), model.end)
				errors.endTime = 'Eindtijd van de stop ligt niet na de ingangstijd'
				errors.hasErrors=true
		else
			errors = super
		
		return errors