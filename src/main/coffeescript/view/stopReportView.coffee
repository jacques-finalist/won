class @StopReportView extends Backbone.View

	constructor : ->
		super()
		$(@el).addClass 'modal'
		$(@el).on 'hidden', @onHide

	show : ->
		$.get(Florence.settings.baseUrl + "/template/stopReport.html", '', (template) =>
			@render(template)
		)

	render : (template) ->
		Florence.eventbus.trigger("showModalDialog")
		$(@el).html _.template(template, {})
		$(@el).modal('show')
		
		@getField('from').val moment().format(Florence.settings.defaultDateFormat)
		@getField('to').val moment().format(Florence.settings.defaultDateFormat)
		@addDatepicker(@getField('from'))
		@addDatepicker(@getField('to'))
		
		$(@el).find('.btn-primary').click =>
			@onGenerate()

	onHide : ->
		window.history.back()

	onGenerate : ->
		errors = @validate()
		if errors.hasErrors
			util.formValidator.displayValidationErrors(@el, errors)
		else
			util.formValidator.removeValidationErrors(@el)
			
			@showProgress()
			@prepareReport()

	showProgress : ->
		$(@el).find('.download').show()
		$(@el).find('.download-result').hide()
		$(@el).find('.download-progress').show()

	prepareReport : ->
		from = @getField("from").val()
		to = @getField("to").val()
		
		$.get(Florence.settings.baseUrl + "/report/stops?from=#{from}&to=#{to}", '', (result) =>
			@showResult(result, from, to)
		)

	showResult : (result, from, to) ->
		$(@el).find('.download-progress').hide()
		$(@el).find('.download-result').show()
		
		downloadUrl = Florence.settings.baseUrl + "/report/stops/download?from=#{from}&to=#{to}"
		
		if (result.results == 0)
			$(@el).find('.download-result').html("""
				<p>Er zijn geen wijzigingen gevonden in de opgegeven periode</p>
			""")
		else
			$(@el).find('.download-result').html("""
				<p>Er zijn #{result.results} wijzigingen gevonden in de opgegeven periode, 
					download het bestand hier: <a href="#{downloadUrl}">#{result.filename}</a></p>
			""")
	
	removeValidationErrors: ->
		$(@el).find('form .error').removeClass('error')
		$(@el).find('form p.help-block').remove()

	validate : ->
		errors = {hasErrors:false}
		
		if !util.formValidator.hasText(@getField("from").val())
			errors.from = 'Vanaf is een verplicht veld'
			errors.hasErrors = true
		if !util.formValidator.hasText(@getField("to").val())
			errors.to = 'Tot is een verplicht veld'
			errors.hasErrors = true
		
		return errors

	addDatepicker: (field) ->
		dateField = field.datepicker({format: Florence.settings.defaultDateFormat.toLowerCase()})
		dateField.val ''
		dateField.on("changeDate", =>
			dateField.datepicker("hide")
		)

	getField : (name) ->
		$(@el).find("form [name='#{name}']")
