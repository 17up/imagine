class window.Veggie.Account extends Backbone.Model
	url: "/members/account"
	parse: (resp)->
		if resp.status is 0
			resp.data