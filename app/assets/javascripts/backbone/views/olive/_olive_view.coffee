class window.Olive.View extends Marionette.ItemView
	initialize: (self = this) ->
		$("#side_nav li[rel='" + @id + "']").addClass('active')
		Utils.loading $("aside .brand")	
		@collection.fetch
			success: ->
				$("article").append(self.render().el)
				Utils.loaded $("aside .brand")
				self.active()
				self.extra()
	close: ->
		@$el.hide()
		$("#side_nav li[rel='" + @id + "']").removeClass('active')
	active: ->
		@$el.show()
		window.route.active_view = this
	extra: ->
		this