#= require_self
#= require_tree ../collections/user_show
#= require_tree ../views/user_show

class UserShow.Router extends Backbone.Router  
	initialize: ->
		this
	routes:
		'':'show'

	show: ->
		new UserShow.TimelineView()