class window.Veggie.GameView extends Marionette.ItemView
	id: "game"
	className: "left"
	template: JST['item/game']
	# collection: new Veggie.Words()
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
		@collection = new Veggie.Words @model.get("data")
		for mission,i in @collection.models
			mission = mission.set num: i
			@addOneMission(mission)
		@imagine_missions()
	back: (e) ->
		window.route.active_view.deinit_imagine()
		$action = $(e.currentTarget).parent()
		$(".info_container",@$el).hide()
		@$el.css "margin-left": "10px"
		@$el.siblings().show()
		@$el.parent().siblings().show()
		$(".banner",@$el).removeClass 'opacity'
		@$el.removeClass("enter_in").addClass("left").css "width":"50%"
		$action.css
			"-webkit-transform": "translateX(120px)"
		$("body").css "overflow":"auto"
		@collection.reset()
		$("#imagine").empty()
		$("#assets").empty()

	addOneMission: (mission,opts = {}) ->
		options = _.extend
			model: mission
			opts
		view = new Veggie.MissionView options
		new_step = view.render().el
		$("#imagine").append(new_step)

	imagine_missions: ->
		window.route.active_view.init_imagine()
		$(".banner",@$el).addClass 'opacity'
