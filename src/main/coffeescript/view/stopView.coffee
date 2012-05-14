class @StopView extends Backbone.View

	constructor: () ->
		super()
		$(@el).addClass('modal')
		$(@el).on('hidden', @onHide)

	renderPage : (ward) ->
		$.get(Florence.settings.baseUrl + "/template/"+@templateViewName, '', (template) =>
			@render(template, ward)
		)

	render: (template, ward) ->
		$(@el).html( _.template(template, @createDefaultValues(ward)))
		$(@el).modal('show')
		$(@el).find('.btn-primary').click =>
			@onSave()
		
	getField : (name) ->
		$(@el).find("form [name='#{name}']")
	
	addDatepicker: (field) ->
		dateField = field.datepicker({format: Florence.settings.defaultDateFormat.toLowerCase()})
		dateField.on("changeDate", =>
			dateField.datepicker("hide")
		)
	
	addTimepicker: (field) ->
		field.timepicker()
		field.data('timepicker')

	createDefaultValues: (ward) ->
		defaultValues =
			beginDate: @currentDateAsString()
			beginTime: @currentTimeAsString()
			endDate: @currentDateAsString()
			endTime: @defaultEndTimeAsString(ward)

	currentTimeAsString : ->
		moment().format(Florence.settings.defaultTimeFormat)

	currentDateAsString : ->
		moment().format(Florence.settings.defaultDateFormat)
	
	defaultEndTimeAsString : (ward) ->
		moment().add('minutes', ward.type.unplannedStopDuration).format(Florence.settings.defaultTimeFormat)
	
	defaultEndDateAsString : (ward) ->
		moment().add('minutes', ward.type.unplannedStopDuration).format(Florence.settings.defaultDateFormat)

	hide: ->
		$(@el).modal('hide')
		
	show:->
		Florence.eventbus.trigger("showModalDialog")

	onHide: ->
		Florence.eventbus.trigger("hideModalDialog")
		window.history.back()

	displayServerErrors: (errors) ->
		switch errors.status
			when 417 then util.formValidator.displayValidationErrors(@el, @convertServerValidations(errors.responseText))
			else @displayUnknownServerError(errors)
	
	convertServerValidations : (responseText) ->
		errors={}
		validationError=$.parseJSON(responseText).validationError
		switch validationError.field
			when "begin" then errors.beginTime=validationError.message
			when "end" then errors.endTime=validationError.message
			else 
				errors[validationError.field]=validationError.message
		return errors

	displayUnknownServerError : (errors) ->
		$('form').prepend "<p class='help-block alert alert-error'>Onbekende fout opgetreden : #{errors.statusText}</p>"
		

	onSave: ->
		errors = @validate(@formToModel())
		
		if errors.hasErrors
			util.formValidator.displayValidationErrors(@el, errors)
		else 
			@stop.save(@formToModel(),
				error : (model,errors) =>
					@handleSaveError(errors)
				success : =>
					@hide()
			)
	
	handleSaveError : (errors) ->
		if !@stop.isNew()
			@stop.fetch()
			
		if errors.status
			@displayServerErrors(errors)
		else
			util.formValidator.displayValidationErrors(@el, errors)
	
	formToModel: ->
		result = {}
		form = $(@el).find('form')
		beginDateTime=''
		endDateTime=''
		
		for field in form.serializeArray()
			switch field.name
				when 'beginTime' then beginDateTime = beginDateTime + " " + field.value
				when 'beginDate' then beginDateTime = field.value + beginDateTime
				when 'endTime' then endDateTime = endDateTime + " " + field.value
				when 'endDate' then endDateTime = field.value + endDateTime
				when 'hours' then continue
				when 'minutes' then continue
				else result[field.name] = field.value
		
		if @validDate(beginDateTime)
			result['begin'] = util.time.momentToArray(moment(beginDateTime,Florence.settings.defaultDateTimeFormat))
		if @validDate(endDateTime)
			result['end'] = util.time.momentToArray(moment(endDateTime,Florence.settings.defaultDateTimeFormat))
		return result

	validate: (model) ->
		errors = {hasErrors:false}
		
		@validateAuthority(errors, model)
		@validateReason(errors, model)
		@validateEnd(errors, model)

		if model.type == 'planned'
			@validateBegin(errors, model)

		return errors
	
	validateAuthority: (errors, model) ->
		if !util.formValidator.hasText(model.authority)
			errors.authority = 'Verantwoordelijke is een verplicht veld'
			errors.hasErrors = true
		if !util.formValidator.hasText(model.position)
			errors.position = 'Functie is een verplicht veld'
			errors.hasErrors = true
	
	validateReason: (errors, model) ->
		if !util.formValidator.hasText(model.description)
			errors.description = 'Reden is een verplicht veld'
			errors.hasErrors = true
	
	validateBegin: (errors, model) ->
		if !model.begin?
			errors.beginTime = 'Ingangstijd is een verplicht veld'
			errors.hasErrors = true
		else if !util.time.dateInFuture(model.begin)
			errors.beginTime = 'Ingangstijd van de geplande stop is niet in de toekomst'
			errors.hasErrors = true

	validateEnd: (errors, model) ->
		if !model.end?
			errors.endTime = 'Eindtijd is een verplicht veld'
			errors.hasErrors = true
		else if model.begin? && !util.time.endAfterBegin(model.begin, model.end)
			errors.endTime = 'Eindtijd van de geplande stop ligt niet na de ingangstijd'
			errors.hasErrors = true

	validDate : (dateText) ->
		dateText.match('^'+Florence.settings.defaultDateTimeFormat.replace('DD','(([0-9])|([0-2][0-9])|([3][0-1]))').replace('MM','(([1-9])|([0][1-9])|([1][0-2]))').replace('YYYY','([0-9][0-9][0-9][0-9])').replace('HH','(([0-9])|([0-1][0-9])|([2][0-3]))').replace('mm','(([0-9])|([0-5][0-9]))')+'$')

