class @CreateStopView extends @StopView

	constructor: () ->
		super()
		@templateViewName="createStop.html"
	
	show: (ward)->
		super
		@stop = new Stop()
		if !ward
			ward=Florence.user.get("ward")
		@renderPage(ward)

	render: (template, ward) ->
		super
		
		@loadWardList(ward)
		
		@getField('ward').bind "change",(event) =>
			if @getSelectedType() == "unplanned"
				selectedWardId = (Number) event.target.value
				@updateDefaultTimes(@getWard(selectedWardId))
		@getField('type').bind "change",(event) =>
			@updateStopType(event.target.value)
		
		@getField('beginDate').val(@currentDateAsString())
		@getField('endDate').val(@currentDateAsString())
		
		@addDatepicker(@getField('beginDate'))
		@addDatepicker(@getField('endDate'))
		@beginTime = @addTimepicker(@getField('beginTime'))
		@endTime = @addTimepicker(@getField('endTime'))
		
		@updateDefaultTimes(ward)

	loadWardList : (ward) ->
		$.get(Florence.settings.baseUrl + "/rest/mywards", '', (result) =>
			@wardList=result.wardList
			@updateWardField()
			@updateSelectedWard(ward)
		)

	getWard : (wardId) ->
		for ward in @wardList
			if ward.id == wardId
				return ward

	getSelectedType: ->
		$(this.el).find("form [name='type']:radio:checked").val()

	updateWardField: ->
		wardField = @getField('ward')
		for ward in @wardList
			option = new Option(ward.type.name,ward.id)
			$(option).text ward.type.name
			wardField.append(option)

	updateDefaultTimes: (ward) ->
		@getField('beginDate').val(@currentDateAsString())
		@getField('endDate').val(@defaultEndDateAsString(ward))
		@beginTime.val(@currentTimeAsString())
		@endTime.val(@defaultEndTimeAsString(ward))

	updateSelectedWard : (ward) ->
		@getField('ward').val(ward.id)

	updateStopType : (type) ->
		if type == 'planned'
			@setPlannedStop() 
		else 
			@setUnplannedStop()

	setUnplannedStop : ->
		@getField('beginDate').attr('disabled', 'disabled')
		@beginTime.disable()
		
		selectedWardId = (Number) @getField('ward').val()
		@updateDefaultTimes(@getWard(selectedWardId))

	setPlannedStop : ->
		@getField('beginDate').removeAttr('disabled').val('')
		@getField('endDate').val('')
		@beginTime.enable().val('')
		@endTime.val('')
