class @ImminentStopsView extends Backbone.View

	constructor:() ->
		@el = $("#stopListView")

	updateState:(imminentStops) ->
		$(@el).html('')
		if imminentStops.length>0
			$.get(Florence.settings.baseUrl + "/template/imminentStopsTable.html", '', (template) =>
				$(@el).html( _.template(template, {stops:@detachFromCollection(imminentStops)}))
			)
	
	#This shouldn't really be necessary but in some way underscores each doesn't work with backbones Collections
	detachFromCollection : (collection) ->
		detachedCollection=[]
		for index in [0 .. collection.length-1]
			detachedCollection.push(collection.at(index))
			
		return detachedCollection
#		return _sortBy(detachedCollection, (stop)->
#			stop.begin
#		)
#		