class window.Veggie.WordView extends Marionette.ItemView
	tagName: 'div'
	className: 'step word'
	id: ->
		@model.get('title')
	attributes: ->
		"data-x": @model.get('num')*2000 + @model.get("sub")*1000
		"data-y": -@model.get('num')*1000
		"data-z": -@model.get('num')*1500
		"data-scale": "1"
	template: JST['item/word']
	events: ->
		"enterStep": "enterStep"
		"leaveStep": "leaveStep"
		"webkitspeechchange .speech input": "speech"
		"focus .speech input": "focus_speech"
		"click .goFirst": "goFirst"
		"click .audio .record": "audio_record"
		"click .audio .play": "audio_play"
		"click .title": "goNext"
		"click .num": "goNext"
	initialize: ->
		#@listenTo(@model, 'change', @render)
		@listenTo(@model, 'destroy', @remove)
		if t = @model.get("title")
			@my_audio = new Audio()
			id = @model.cid
			@sound = soundManager.createSound
				id: id
				url: "http://tts.yeshj.com/uk/s/" + encodeURIComponent(t)
	goFirst: (e) ->
		$("#imagine").jmpress "goTo",$("#ihome")
	goNext: ->
		$("#imagine").jmpress 'next'
	focus_speech: (e) ->
		$(e.currentTarget).blur()
	speech: (e) ->
		$ele = $(e.currentTarget)
		key = $ele.data().key
		w = $ele.val()
		if w.toLowerCase() is key
			Utils.flash("发音很准哦！","success")
		else
			Utils.flash("#{w}? 还差一点，加油！","error")
		$ele.blur().val('')
		setTimeout(=>
			@sound.play()
		,500)
	enterStep: (e) ->
		max = ($("#imagine .step").length+1)/3
		percent = @model.get('num')*100/max
		$("#progress .current_bar").css "width": "#{percent}%"
		$ele = $(e.currentTarget)
		if @sound
			@sound.play()
		if @model.get('num') is 0
			Veggie.GuideView.addOne Guide.imagine("ihome")
		else if @model.get("num") is max
			Veggie.GuideView.addOne Guide.imagine("iend")
		if @model.get("sub") is 1
			Veggie.GuideView.addOne Guide.imagine("word")

	audio_record: (e) ->
		self = this
		_id = @model.get("_id")
		$btn = $(e.currentTarget)
		if navigator.webkitGetUserMedia or navigator.getUserMedia
			window.recorder = window.recorder || new AudioRecorder()
			window.recorder.startRecording ->
				$btn.addClass 'ing'
				setTimeout( ->
					window.recorder.stopRecording ->
						$btn.removeClass 'ing'
						window.recorder.createDownloadLink(self.my_audio,_id)
				,3000)
		else
			Utils.flash "您的浏览器不支持语音输入，请尝试chrome","error"
	audio_play: (e) ->
		if @my_audio.src isnt ''
			@my_audio.play()
		else if src = @model.get("my_audio")
			@my_audio.src = src
			@my_audio.play()
		else
			Utils.flash("你还没有录音呢，请点击我左边那家伙先录个音吧！","error")

