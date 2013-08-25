class window.Veggie.Dashboard extends Backbone.Model
	url: "/members/dashboard"
	parse: (resp)->
		if resp.status is 0
			resp.data
			