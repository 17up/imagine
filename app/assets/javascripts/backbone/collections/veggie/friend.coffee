class window.Veggie.Friend extends Backbone.Collection
	url: "/members/friend"
	parse: (resp)->
		if resp.status is 0
			resp.data