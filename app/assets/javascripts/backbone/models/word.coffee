class window.Word extends Backbone.Model
	defaults:
		"title": ''
		"content": ''
		"imagine": false
		"synset": []
		"sentence": []
	fetch: (callback) ->
		params = title: @.get("title")
		$.post "/words/fetch",params, (data) =>
			if data.status is 0
				@.set data.data
				callback() if callback

		