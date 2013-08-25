class window.UserShow.TimelineView extends Marionette.ItemView
	collection: new UserShow.Timeline()
	id: "timeline"
	template: JST['timeline_view']
	initialize: (self = this) ->
		@collection.fetch
			url: "/members/timeline?_id=" + $("#user_info").data().uid
			success: ->
				$("section").append(self.render().el)
	render: ->
		template = @template()
		@$el.html(template)		
		this