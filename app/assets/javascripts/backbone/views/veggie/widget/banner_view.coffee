class window.Veggie.BannerView extends Marionette.ItemView
	id: "nav"	
	template: JST['banner_view']
	model: new Member()
	events: ->
		"click .avatar": "upload_avatar"
		"click .style": "change_style"
	initialize: ->
		@model.fetch
			success: =>
				if $.jStorage.get "layout_style"
					@model.set layout: 'wis'
				$("nav").html(@render().el)
		window.current_member = @model
	upload_avatar: (e) ->
		Utils.uploader($(e.currentTarget))
	change_style: (e) ->
		$ele = $(e.currentTarget)
		$ele.siblings().show()
		$ele.hide()
		style = $ele.attr 'rel'
		if style is "day"
			$('body').addClass 'wis'
			$.jStorage.set "layout_style","wis"
		else
			$('body').removeClass 'wis'
			$.jStorage.set "layout_style",null