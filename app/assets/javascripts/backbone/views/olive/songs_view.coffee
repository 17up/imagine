class window.Olive.SongsView extends Olive.View
	id: 'songs'
	className: "block"
	template: JST['songs_view']
	collection: new Olive.Song()
	events:
		"paste #upload_songs textarea": "parse_lyrics"
		"click .uploader": "upload_song"
	render: ->
		template = @template()
		@$el.html(template)				
		this
	add_one: (model) ->
		view = new Olive.SongView
			model: model
		$("#recent_songs",@$el).append(view.render().el)
	upload_song: ->
		Utils.uploader $("#upload_songs .uploader"), (data) =>
			@song.set data
			@add_one(@song)
			$("form",@$el)[0].reset()
	parse_lyrics: (e) ->
		setTimeout(=>
			text = $(e.currentTarget).val()
			lyrics = new Lrc text
			tags = lyrics.tags
			$("input[name='title']",@$el).val(tags["title"])
			$("input[name='artist']",@$el).val(tags["artist"])
			$("input[name='album']",@$el).val(tags["album"])
			if $.trim(tags["title"]) isnt ''
				@song = new Song()
				$form = $(e.currentTarget).closest("form")
				obj = $form.serializeArray()
				serializedData = {}
				$.each obj, (index, field)->
					serializedData[field.name] = field.value
				@song.save serializedData,success: (m,resp) =>
					$("#uploader .song input[name='_id']").val resp.data
					$(".uploader",@$el).show()
		,100)	
	extra: ->		
		for s in @collection.get("songs")
			song = new Song(s)
			@add_one(song)
		super()