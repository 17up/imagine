#= require_self
#= require ./routers/user_show_router

class window.UserShow
	constructor: ->
		$("body").addClass 'veggie'
		window.route = new UserShow.Router()
		Backbone.history.start()