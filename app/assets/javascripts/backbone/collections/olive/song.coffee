class window.Olive.Song extends Backbone.Model
	url: "/olive/songs"
	parse: (resp)->
		if resp.status is 0
			resp.data