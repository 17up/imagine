#= require_self
#= require_tree ../collections/olive
#= require_tree ../views/olive

class Olive.Router extends Backbone.Router  
	initialize: ->
		self = this
		$("#side_nav li").click ->
			href = $(@).attr 'rel'
			$(@).addClass('active')
			self.navigate(href,true)
	routes:
		'':'courses'
		'courses': 'courses'
		'quotes': 'quotes'
		'songs': "songs"
	before_change: ->
		if window.route.active_view
			window.route.active_view.close()
	courses: ->
		@before_change()
		if @courses_view
			@courses_view.active()
		else
			@courses_view = new Olive.CoursesView()
	quotes: ->
		@before_change()
		if @quotes_view
			@quotes_view.active()
		else
			@quotes_view = new Olive.QuotesView()
	songs: ->
		@before_change()
		if @songs_view
			@songs_view.active()
		else
			@songs_view = new Olive.SongsView()