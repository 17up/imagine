class window.Utils
	@loading: ($item) ->
		$item.addClass 'disable_event'
		$item.queue (next) ->
			$(@).animate({opacity: 0.2},800).animate({opacity: 1},800)
			$(@).queue(arguments.callee)
			next()
	@loaded: ($item) ->
		$item.stop(true).css "opacity",1
		$item.removeClass 'disable_event'
	# single uploader
	@uploader: ($ele,callback) ->				
		$uploader = $("footer #uploader").find("." + $ele.data().uploader)		
		$file = $("input[type='file']",$uploader)
		$form = $file.closest('form')
		$img = $("img",$ele)
		$form.off "ajax:success"
		$form.on "ajax:success",(d,data) ->
			if data.status is 0
				Utils.flash(data.msg,'success')
				if callback
					callback(data.data)
				else
					$img.attr("src",data.data)
			else
				Utils.flash(data.msg,'error')
		$file.off 'change'
		$file.on 'change', ->
			$form.submit()
		$file.trigger "click"
		$form
	
	@tag_input: ($form) ->
		$("input.tags",$form).each (i,e) ->
			tip = $(@).data().tip || "添加标签"
			delimiter = $(@).data().delimiter || ","
			$(@).tagsInput
				'height':'auto'
				'width':'auto'
				'defaultText': tip			
				'placeholderColor': '#888'
				'delimiter': delimiter
	# Utils.getSelection('Italic')
	# Utils.getSelection('bold')
	@getSelection: (command = 'bold') ->
		if window.getSelection
			select = window.getSelection()
			if select.rangeCount
				range = select.getRangeAt(0)
				document.designMode = "on"
				select.removeAllRanges()
				select.addRange(range)
				document.execCommand(command, null, false)
				document.designMode = "off"
				$.trim(new String(select).replace(/^\s+|\s+$/g,''))

	@active_tab: (id) ->
		$("ul.tab li a[href='#"+id+"']").parent().addClass('active').siblings().removeClass("active")
	@flash: (msg,type='',$container) ->
		$container = $container || $("#flash_message")
		$container.prepend JST['widget/flash'](msg:msg)
		$alert = $(".alert:first-child",$container)
		if type isnt ''
			$alert.addClass "alert-#{type}"
		$alert.slideDown()
		fuc = -> 
			$alert.slideUp ->
				$(@).remove()
		setTimeout fuc,5000		
		false
	@show_word_tips: (msg,$container) ->
		$container = $container || $("#flash_message")
		$container.html JST['widget/flash'](msg:msg)
		$(".alert",$container).addClass("alert-success").show()

	@wd_count: (string) ->
		cn_regx = /[\u4E00-\u9FA5\uf900-\ufa2d]/ig
		has_cn = string.match(cn_regx)
		if has_cn
			cn_count = has_cn.length
			string = string.replace(cn_regx,'')
		else
			cn_count = 0
		en_count = (_.compact(string.split(" "))).length
		en_count + cn_count
	@ms_flash: ($alert,duration) ->
		$alert.css 		
			"-webkit-transform": "translateY(300px)"
			"-webkit-transition": "0.8s"
		fade_in = ->
			$alert.css 
				"-webkit-transform":"translateY(0px)"
		fade_out  = ->
			$alert.css 
				"-webkit-transform":"scale(1.5)"
				"opacity": "0.0"
			$alert.on "webkitTransitionEnd",->
				$(@).remove()
		setTimeout fade_in,100
		if duration
			setTimeout fade_out,duration
	@message: (avatar,msg,style = '',$container) ->
		$container = $container || $("#chatroom .ms_text_box")
		wc = Utils.wd_count(msg)
		$container.prepend JST['widget/message'](avatar:avatar,msg:msg)
		$alert = $(".ms:first-child",$container)
		if style isnt ''
			$alert.addClass "alert-#{style}"		
		if wc > 6 
			duration = wc*1100 
		else
			duration = 7000
		Utils.ms_flash $alert,duration
		false
	# 音频播放器
	@record: (avatar,url) ->
		$container = $("#chatroom .ms_audio_box")
		$container.prepend JST['widget/audio_player'](avatar:avatar,url:url)
		$alert = $(".media:first-child",$container)
		Utils.ms_flash $alert
		new InlinePlayer()
	@confirm: (msg,yesCallback) ->
		$("body").prepend JST['widget/confirm'](msg:msg)
		$confirm = $("#confirm_dialog")
		$alert = $(".form",$confirm)
		$("#container").addClass 'mask'
		$alert.fadeIn()
		$(".btn",$confirm).click ->
			if $(@).data().confirm is true
				yesCallback()	
			$confirm.remove()	
			$("#container").removeClass 'mask'
		false