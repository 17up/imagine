class window.Veggie.TeachView extends Veggie.View
	id: "teach"
	className: "common"
	template: JST['teach_view']
	collection: new Veggie.Teach()
	events:
		"click .new": 'newCourse'
	close: ->
		super()
		@deinit_imagine()
	active: ->
		super()
		if @current_course and @current_course.get("fetch_word")
			@init_imagine()
	deinit_imagine: ($ele = $("#t_words")) ->
		if $ele.jmpress("initialized")
			$ele.jmpress "deinit"
		$ele.hide()
		$("#t_control").removeClass 'active'
		@$el.css "height":"auto"
		
	init_imagine: ($ele = $("#t_words")) ->
		unless $ele.jmpress("initialized")		
			$ele.jmpress
				stepSelector: ".t_word"
				transitionDuration: 0
				hash:
					use: false
				mouse:
					clickSelects: false
				keyboard:
					keys:
						9: null
						32: null
			$ele.show()
			$("#t_control").show().addClass 'active'
			@$el.css "height":"100%"
	extra: ->
		if @collection.models.length is 0
			guide = Guide.generate "你已经成为 17up 学会的教师了，赶快创建你的第一课吧"
			Veggie.GuideView.addOne(guide,$("#t_assets"))
		@collection.push(new Course())
		tcv = new Veggie.TeachCoursesView
			collection: @collection				
		@$el.append(tcv.render().el)
		super()