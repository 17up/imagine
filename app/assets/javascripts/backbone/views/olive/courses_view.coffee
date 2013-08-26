class window.Olive.CoursesView extends Olive.View
	id: 'courses'
	className: "block"
	template: JST['courses_view']
	collection: new Olive.Courses()
	events:
		"change #c_filter": "filter"
	addOne: (course) ->
		view = new Olive.CourseView
			model: course
		$("#courses",@$el).append(view.render().el)
	render: ->
		template = @template()
		@$el.html(template)				
		this
	filter: (e) ->
		status = $(e.currentTarget).val()
		@collection.fetch
			url: @collection.url + "?status=" + status
			success: (data) =>
				$("#courses",@$el).html("")
				@addCourses()
	addCourses: ->
		for c in @collection.models
			@addOne(c)
	extra: ->
		$("#c_filter").fancySelect()
		@addCourses()
		super()