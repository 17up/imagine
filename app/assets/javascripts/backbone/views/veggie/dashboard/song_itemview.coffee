class window.Veggie.SongView extends Marionette.ItemView
	id: "song"
	className: "left"
	template: JST['item/song']
	open: false
	events:
		"click .back": "back"
		"click .play": "play"
		"click .pause": "pause"
		"click .like": "like"
	back: (e) ->
		$action = $(e.currentTarget).parent()
		@open = false
		$(".panel",@$el).hide()
		@audio.stop()
		@$el.siblings().show()
		@$el.parent().siblings().show()
		@$el.removeClass("playing").addClass("left").css "width":"50%"	
		$(".banner",@$el).removeClass 'opacity'
		$action.css 
			"-webkit-transform": "translateX(120px)"
		$("#icontrol").removeClass 'active'
		$(".lyrics_container",@$el).empty()
		$("body").css "overflow":"auto"
	initialize: ->
		@audio = soundManager.createSound
			id: @model.get("_id") || "17music"
			url: @model.get("url")
			autoLoad: true
	play: (e) ->
		$ele = @$el
		$("body").css "overflow":"hidden"
		@$el.addClass "playing"	
		$(".banner",@$el).addClass 'opacity'
		play_song = =>
			@lyrics = new Lrc @model.get("lyrics"),(text,ex) =>
				$(".lyrics_container",@$el).append JST['item/lrc'](text: text)
				$alert = $(".lyrics:last-child",@$el)
				@fade_out($alert.siblings())
				@fade_in($alert)
			@audio.play
				onplay: =>
					@lyrics.play(0)
				onfinish: =>
					@$el.removeClass("playing")
				onpause: =>
					@lyrics.pauseToggle()
				onresume: =>
					@lyrics.pauseToggle()
				onstop: =>
					@lyrics.stop()
				whileplaying:  ->
					percent = @position*100/@duration
					$("#progress .current_bar").css "width": "#{percent}%"			
			$("#icontrol").show().addClass 'active'
		if @open
			if @audio.paused
				@audio.resume()
			else
				play_song()
		else
			$action = $(e.currentTarget).parent()
			@open = true
			Veggie.hide_nav =>
				width = $(window).width() - 48
				@$el.removeClass("left").animate
					"width": width + "px"
					800
					-> 
						$(@).css "width": "auto"
						$action.css 
							"-webkit-transform": "translateX(0)"	
						$(".panel",$ele).show()				
			@$el.parent().siblings().hide()
			@$el.siblings().hide()
			play_song()
	pause: (e) ->
		unless @audio.paused
			@audio.pause()
			@$el.removeClass "playing"
	fade_in: ($txt) ->
		setTimeout( ->
			$txt.css 
				"-webkit-transform":"scale(1) translateY(170px)"
				"opacity": "1"
		,1)		
	fade_out: ($txt) ->
		$txt.css 
			"-webkit-transform":"scale(1.5)"
			"opacity": "0.0"
		$txt.on "webkitTransitionEnd",->
			$(@).remove()
	like: (e) ->
		@model.liked (cnt)->
			$(e.currentTarget).fadeOut()
			if cnt is 1
				Utils.flash "感动,你是第一个说赞的同学哦，握爪"
			else
				Utils.flash("感谢你的赞，还有 " + (cnt - 1) + " 同学也觉得很赞!")
		false