class window.Provider extends Backbone.Model
	defaults:
		"_id": ''
		"provider": ''
	fetch: (callback) ->
		if @.get("_id") is ''
			$.get "/members/provider?provider=" + @.get("provider"), (data) =>
				if data.status is 0
					@.set data.data
					callback() if callback
		
