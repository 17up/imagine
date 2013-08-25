class window.Veggie.View extends Marionette.ItemView
	initialize: (self = this) ->
		Utils.loading $("nav .brand")	
		m = @model || @collection
		m.fetch
			success: ->
				$("article").append(self.render().el)
				Utils.loaded $("nav .brand")			
				self.extra()
				self.active()
	close: ->
		@$el.hide()
		$("#side_nav li[rel='" + @id + "']").removeClass('active')
	active: ->
		@$el.show()
		$("#side_nav li[rel='" + @id + "']").addClass('active')
		window.route.active_view = this
	extra: ->
		this