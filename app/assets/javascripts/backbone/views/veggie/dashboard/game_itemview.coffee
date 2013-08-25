class window.Veggie.GameView extends Marionette.ItemView
	id: "game"
	className: "left"
	template: JST['item/game']
	events:
		"click .enter": "enter"
		"click .back": "back"
		"click .upload_img": "upload_img"
	enter: (e) ->
		@$el.addClass "enter_in"
		$("body").css "overflow":"hidden"	
		@$el.css "margin-left": "0"		
		$action = $(e.currentTarget).parent()
		Veggie.hide_nav =>
			width = $(window).width() - 48
			@$el.removeClass("left").animate
				"width": width + "px"
				800
				-> 
					$(@).css "width": "auto"
					$(".info_container",$(@)).fadeIn()
					$action.css 
						"-webkit-transform": "translateX(0)"
		@$el.parent().siblings().hide()
		@$el.siblings().hide()
	back: (e) ->
		$action = $(e.currentTarget).parent()
		$(".info_container",@$el).hide()
		@$el.css "margin-left": "10px"
		@$el.siblings().show()
		@$el.parent().siblings().show()
		@$el.removeClass("enter_in").addClass("left").css "width":"50%"	
		$action.css 
			"-webkit-transform": "translateX(120px)"
		$("body").css "overflow":"auto"
	addOneMission: (mission) ->
		view = new Veggie.MissionView
			model: mission		 
		new_step = view.render().el
		$("#imagine").append(new_step)
	
	imagine_missions: ->		
		window.route.active_view.init_imagine()
		@$el.addClass 'opacity'