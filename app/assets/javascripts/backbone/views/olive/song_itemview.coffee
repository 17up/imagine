class window.Olive.SongView extends Marionette.ItemView
	className: "form alert-success song"
	template: JST['item/o_song']
	events:
		"click .preview": "preview"
	render: ->
		@lyrics = new Lrc @model.get("lyrics")		
		@model.set 
			lyrics: @lyrics.txts
		@$el.html @template(@model.toJSON())
		this
	preview: ->
		$(".lyrics_container",@$el).toggle()		
		this