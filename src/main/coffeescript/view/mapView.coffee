class @MapView extends Backbone.View

	constructor:() ->
		@el = $("#mapView")
		@markers = []
		myOptions = 
			zoom: 8
			center: new google.maps.LatLng(52.639730, 4.833984)
			mapTypeId: google.maps.MapTypeId.ROADMAP
			mapTypeControlOptions: 
				style: google.maps.MapTypeControlStyle.DROPDOWN_MENU
				mapTypeIds: [google.maps.MapTypeId.ROADMAP,google.maps.MapTypeId.SATELLITE]
		
		@map = new google.maps.Map(document.getElementById('googleMapsView'),myOptions)

	rescale: ->
		$("#googleMapsView").height($(window).height() - 190)
		$("#googleMapsView").width($("#mapView").width())
		
	updateState:(locationStates) ->
		@clearCurrentState()
		if locationStates.length > 0
			@showState(locationStates.at(index)) for index in [0 .. locationStates.length-1]
		
	clearCurrentState: ->
		if @markers
			marker.setMap(null) for marker in @markers
		@markers = []

	showState:(state) ->
		marker=@createMarker(state)
		@addInfoWindow(marker,state)
		@markers.push(marker)
		
	addInfoWindow:(marker,state) ->
		marker.infoWindow = new InfoWindowView(marker, @map, state.get("hospitalName"))
		marker.infoWindow.updateState state
	
	createMarker:(state) ->
		if state.hasActiveStops()
			markerColor='red'
		else if state.hasStopsAtHand()
			markerColor='green-warning'
		else
			markerColor='green'
		return new google.maps.Marker
			position: new google.maps.LatLng(state.get('latitude'),state.get('longitude'))
			map:@map
			title:state.get('hospitalName')
			icon : new google.maps.MarkerImage("../images/#{markerColor}-dot.png")
	
	getMarker : (title) ->
		return if marker.getTitle() is title for marker in @markers
		
		
class @MapViewDebug extends MapView

	constructor:() ->
		super()
		@debugView=$('<div id="debugMarkerList" style="display:block"/>')
		@el.append(@debugView)

	createMarker:(state) ->
		marker=super
		@debugView.append(@createMarkerLink(marker,state))
		marker
		
	clearCurrentState: ->
		super
		@debugView.html('')
	
	createMarkerLink : (marker,state) ->
		link = $("<a data-lat='#{state.get("latitude")}' data-lng='#{state.get("longitude")}'>#{state.get("hospitalName")}</a>")
		link.click ->
			google.maps.event.trigger(marker,'click')