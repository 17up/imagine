class window.Olive.Quote extends Backbone.Model
	url: "/olive/quotes"
	parse: (resp)->
		if resp.status is 0
			resp.data

	