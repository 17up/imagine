#= require_self
#= require ./routers/olive_router

class window.Olive
	constructor: ->
		$("body").addClass 'olive'
		window.route = new Olive.Router()
		Backbone.history.start
			root: 'o'