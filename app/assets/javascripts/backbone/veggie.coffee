#= require_self
#= require ./routers/veggie_router

class window.Veggie
	constructor: ->
		$("body").addClass 'veggie'
		if $.jStorage.get "layout_style"
			$('body').addClass 'wis'
		window.route = new Veggie.Router()
		Backbone.history.start
			pushState: true

		$(document).bind "keyup.nav",(e) ->
			switch e.keyCode
				when 27 # esc
					new Sound("nav")
					if $("nav").is(":visible")
						Veggie.hide_nav()
					else
						Veggie.show_nav()
					false
				when 70 # F
					if $("input:focus,textarea:focus").length is 0
						element = document.body
						requestMethod = element.requestFullScreen ||
								element.webkitRequestFullScreen ||
								element.mozRequestFullScreen ||
								element.msRequestFullScreen
						if requestMethod
							requestMethod.apply(element)
					else
						false
	@hide_nav: (callback) ->
		$("#flash_message .alert").remove()
		$("nav").animate 
			"top": "-86px"
			500
			 ->
			 	$(@).hide()
			 	$("article .common").animate 'top':0
			 	callback() if callback
		$("aside").animate 
			"left":"-86px"
			500
			->
				$(@).hide()
				$("article").animate 'margin-left':0
	@show_nav: ->
		$("nav").show().animate 
			"top": "0px"
			500
			->
				$(@).css 'top':'auto'
		$("aside").show().animate 
			"left":"0px"
		$("article").animate 'margin-left':'86px'
		$("article .common").animate 'top':'86px'
