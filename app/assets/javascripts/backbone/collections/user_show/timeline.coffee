class window.UserShow.Timeline extends Backbone.Collection
	model: TimePiece
	url: "/members/timeline"
	parse: (resp)->
		if resp.status is 0
			resp.data