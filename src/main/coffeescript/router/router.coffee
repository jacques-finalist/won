class @Router extends Backbone.Router
	
	routes:
		"main" : "showMainPage"
		"workout" : "showWorkoutPage"
		"selectLocation" : "showWorkoutPage"
		"options" : "showWorkoutPage"
		
	showMainPage: ->
		$("#page-content").html(won.templates.menu)
		
	showWorkoutPage: ->
		console.log("showing workout page")
		
	showWorkoutPage: ->
		console.log("showing select location page")