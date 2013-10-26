class window.Veggie.DashboardView extends Veggie.View
	id: "dashboard"
	className: "common"
	template: JST['dashboard_view']
	model: new Veggie.Dashboard()
	add_song: ->
		model = new Song(@model.get("song"))
		@song_view = new Veggie.SongView
			model: model
		$("#widgets",@$el).append(@song_view.render().el)
	add_courses: ->
		@courses = new Veggie.Courses(@model.get("courses"))
		cv = new Veggie.CoursesView
			collection: @courses
		@$el.append(cv.render().el)
	add_game: ->
		model = new Game(@model.get("game"))
		game_view = new Veggie.GameView
			model: model
		$("#widgets",@$el).append(game_view.render().el)
	active: ->
		super()
		if @current_course and @current_course.get("imagine")
			@init_imagine()
		if @current_game
			@init_imagine()
	close: ->
		super()
		@deinit_imagine()
	deinit_imagine: ->
		if $("#imagine").jmpress("initialized")
			$("#imagine").jmpress "deinit"
		$("#imagine").hide()
		$("#icontrol").removeClass 'active'
		@$el.css "height":"auto"

	init_imagine: ->
		unless $("#imagine").jmpress("initialized")
			$("#imagine").jmpress
				stepSelector: ".step"
				transitionDuration: 0
				hash:
					use: false
				mouse:
					clickSelects: false
				keyboard:
					keys:
						9: null
						32: null
						# 37: null
						# 39: null
			if $("#imagine").find("#iend").length isnt 0
				$("#imagine").jmpress("route", "#iend", true)
			if $("#imagine").find("#ihome").length isnt 0
				$("#imagine").jmpress("route", "#ihome", true, true)
			if @current_course
				cid = @current_course.get("_id")
				if step = $.jStorage.get "course_#{cid}"
					$("#imagine").jmpress "goTo","#" + step
			$("#imagine").show()
			$("#icontrol").show().addClass 'active'
			@$el.css "height":"100%"

	keyup: (event) ->
		switch event.keyCode
			when 39
				$(".next:visible").trigger("click")
	addOneGuide: (guide) ->
		view = new Veggie.GuideView
			model: guide
		$("#assets").append(view.render().el)
	render_member_view: ->
		@add_song()
		@add_courses()
		window.chatroom = new Veggie.ChatView()
	extra: ->
		if @model.has("guides")
			$("#side_nav li:first-child").siblings().hide()
			Veggie.hide_nav()
			guides = @model.get("guides")
			Guide.fetch(guides)
			for g,i in guides["member"]
				@addOneGuide(Guide.generate(g,i+1))
			$(document).on('keyup', @keyup)
		else
			@render_member_view()
		super()
