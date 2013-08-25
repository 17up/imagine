class window.Song extends Backbone.Model
	defaults:
		"_id": ""
		"title": 'love of my life'
		"url": 'http://17up.org/audios/friends.m4a'
		"artist": "Queen"
	url: "/songs/create"
	liked: (success) ->
		$.post "/members/like",obj: "Song",_id: @.get("_id"),(data) =>
			if data.status is 0
				@.set
					liked: true
				success(data.data) if success

