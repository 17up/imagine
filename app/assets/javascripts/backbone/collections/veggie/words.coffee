class window.Veggie.Words extends Backbone.Collection
	model: Word
	parse: (resp)->
		if resp.status is 0
			resp.data