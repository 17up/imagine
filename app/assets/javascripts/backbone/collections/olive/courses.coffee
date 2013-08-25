class window.Olive.Courses extends Backbone.Collection
	model: Course
	url: "/olive/courses"
	parse: (resp)->
		if resp.status is 0
			resp.data.courses