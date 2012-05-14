class @InfoWindowView extends Backbone.View

	constructor: (marker, map, dataName)->
		@map=map
		@marker = marker
		@dataName = dataName
		@createInfoWindow()
	
	updateState : (state) ->
		$.get(Florence.settings.baseUrl + "/template/locationDetails.html", '', (template) =>
			@setContent template, state
		)

	createInfoWindow : ->
		@infoWindow=new InfoBox
			boxClass: "info-window"
			closeBoxMargin: "2px -2px 2px 2px"
			maxWidth: 0
			alignBottom: true
			pixelOffset: new google.maps.Size(-90, -30)
		@bindEvents()
		
	setContent : (template, state) ->
		@infoWindow.setContent _.template(template, 
			wards:state.getWards()
			dataName: @dataName
		)
		
	bindEvents : ->
		google.maps.event.addListener(@marker,'click', =>
			@infoWindow.open(@map,@marker)
		)
		google.maps.event.addListener(@infoWindow,'domready', =>
			@getDetailsLink().bind 'click', (event)=>
				@toggleDetails event.target
		)
		google.maps.event.addListener(@infoWindow,'closeclick', =>
			@getDetailsLink().unbind 'click'
		)
	
	getDetailsLink : ->
		@getInfoWindowDom().find("div[data-type='ward-info'] a[data-action='details']")
	
	getInfoWindowDom : ()->
		$(".info-window div[data-name='#{@dataName}']")
		
	toggleDetails : (context)->
		$(context).parent().find(".details").toggle()
		$(context).toggleClass("icon-plus").toggleClass("icon-minus")
		if $(context).parent().find(".details").is(":visible")
			$("div[data-name='#{@dataName}']").parent().width("auto")
		else
			$("div[data-name='#{@dataName}']").parent().width("auto")
