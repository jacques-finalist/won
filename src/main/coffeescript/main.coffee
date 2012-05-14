$(document).bind("mobileinit", -> 
	$.mobile.hashListeningEnabled = false
	console.log("disabled jquery mobile")
)

$ ->
	router=new Router()
	router.showMainPage()
	Backbone.history.start()
	 