class window.Veggie.Teach extends Backbone.Collection
	model: Course
	url: "/members/teach"
	parse: (resp)->
		if resp.status is 0
			resp.data