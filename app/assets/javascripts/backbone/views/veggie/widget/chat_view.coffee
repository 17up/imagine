class window.Veggie.ChatView extends Marionette.ItemView
	id: "chatroom"
	template: JST['widget/chatroom']
	collection: new Veggie.Members()
	events:
		"click .invite": "invite"
		"click .close": "close_invite"
		"click .share": "send_invite"
		"click span.speech": "record"
		"keyup": "chat"
	initialize: ->	
		$("body").append(@render().el)
		if location.href.match(/17up.org/)
			@dispatcher = new WebSocketRails('17up.org:3001/websocket')
		else
			@dispatcher = new WebSocketRails('localhost:3000/websocket')

		@dispatcher.on_open = (data) ->
			uid = window.current_member.get("_id")
			@notify_channel = this.subscribe("notify_" + uid)
			@notify_channel.bind "invite_course", (data) ->
				$("#courses .headline").after JST["widget/notice"](msg: data)
	chat: (event) ->
		if event.keyCode is 13
			$content = $("#chat_content")
			content = $.trim($content.val())
			wc = Utils.wd_count(content)
			if content is ""
				$content.val("").focus()
			else if wc > 20
				Utils.flash("#{wc} 个词太长啦，发言简短更显才气！","error",@$el)
			else
				@send_message(content)
				$content.val("").focus()
			mixpanel.track("chat","name":window.current_member.get("name"))
					
	record: (e,timeout = 10) ->
		$btn = $(e.currentTarget)
		@speech_audio = new Audio()
		$ts = (new Date()).getTime()
		self = this
		if navigator.webkitGetUserMedia or navigator.getUserMedia
			window.recorder = window.recorder || new AudioRecorder()
			window.recorder.startRecording ->			
				Utils.loading $btn			
				setTimeout( ->
					window.recorder.stopRecording ->
						Utils.loaded $btn
						window.recorder.createDownloadLink(self.speech_audio,$ts,"/members/upload_audio")
						# 通知其他人 ts & current_member
						message = 
							cid: self.channel.name
							ts: $ts
							uid: window.current_member.get("_id")
						self.dispatcher.trigger('new_record', message)
				,timeout*1000)			
		else
			Utils.flash "您的浏览器不支持语音输入，请尝试chrome","error"
	send_message: (content) ->
		message = 
			cid: @channel.name
			_id: window.current_member.get("_id")
			content: content

		@dispatcher.trigger('new_message', message)
	enter_channel: (channel_id) ->		
		@channel = @dispatcher.subscribe(channel_id)
		data = 
			cid: channel_id
			uid: window.current_member.get("_id")
		@dispatcher.trigger('enter_channel',data)
		@$el.show()
		@channel.bind 'enter', (data) =>
			is_newer = @collection.length is 0
			if is_newer
				for m in data.guys
					@collection.push(new Member(m))			
				@collection.push(new Member(data.newer))
				for i in [1..(5 - @collection.length)]
					@collection.push(new Member())
			else
				m = @collection.where(_id: '')[0]
				m.set data.newer		
				Utils.message(m.get("avatar"),"welcome " + m.get("name"),"info")
		@channel.bind 'success', (ms) =>
			m = @collection.where(_id: ms._id)[0]
			if ms._id is window.current_member.get("_id")
				style = "success"
			else
				style = "info"
			Utils.message(m.get("avatar"),ms.content,style)
		@channel.bind 'leave', (data) =>
			m = @collection.where(_id: data._id)[0]
			m.set m.defaults
		@channel.bind "new_record", (ms) =>
			m = @collection.where(_id: ms.uid)[0]
			unless ms.uid is window.current_member.get("_id")
				Utils.record(m.get("avatar"),ms.url)
	leave_channel: ->
		@$el.hide()
		data = 
			cid: @channel.name
			uid: window.current_member.get("_id")
		@dispatcher.trigger('leave_channel',data)
		@channel._callbacks = []
		@collection.reset()
		$("#chatroom #oline_users").empty()
	invite: ->
		$(".container",@$el).fadeOut 300, =>
			$("#invite",@$el).fadeIn(300)
		$("#invite .cname").text window.route.active_view.current_course.get("title")
	close_invite: ->
		$wrap = @$el
		$("#invite",$wrap).fadeOut 300, ->
			$(".container",$wrap).fadeIn 300
	send_invite: ->
		$wrap = @$el
		msg = $.trim $(".message",@$el).text()
		cid = window.route.active_view.current_course.get("_id")
		$.post "/members/send_invite",
			msg: msg
			course_id: cid
			(data) =>
				if data.status is 0
					@close_invite()
					setTimeout( ->
						Utils.flash("邀请将在您的微博上发出，您的好友一旦接受邀请，小柒会立即通知您",'success',$wrap)
					,1000)
				else if data.status is 1
					Utils.flash("成功啦，您的好友很快会收到您的邀请！","error",$wrap)
				else
					Utils.flash("啊呀，邀请失败啦","error",$wrap)
