class window.AudioRecorder
	constructor: ->
		self = this
		window.AudioContext = window.AudioContext || window.webkitAudioContext
		navigator.getUserMedia = navigator.getUserMedia || navigator.webkitGetUserMedia
		window.URL = window.URL || window.webkitURL			
		self.audio_context = new AudioContext
	startRecording: (callback) ->
		self = this
		startUserMedia = (stream) ->
			input = self.audio_context.createMediaStreamSource(stream)
			input.connect(self.audio_context.destination)
			self.recorder = new Recorder(input)	
			self.recorder.record()
			callback()	
		if self.recorder isnt undefined
			self.recorder.record()
			callback()	
		else			
			navigator.getUserMedia
				audio: true
				startUserMedia
				(e) ->
					Utils.flash("请允许使用您的麦克风哦！","error")
					false
			
	stopRecording: (callback) ->
		self = this
		self.recorder && self.recorder.stop()
		callback()
		self.recorder.clear()
	createDownloadLink: (my_audio,_id,post_url = '/words/upload_audio_u') ->
		self = this
		self.recorder and self.recorder.exportWAV (blob) ->
			url = URL.createObjectURL(blob)	
			my_audio.src = url
			my_audio.play()
			form = new FormData()
			form.append("file", blob)
			form.append("_id",_id) if _id
			form.append("authenticity_token",$("footer #uploader .audio form").find("input[name='authenticity_token']").val())
			oReq = new XMLHttpRequest()
			oReq.open("POST",post_url)
			oReq.send(form)
