class window.Olive.CourseView extends Marionette.ItemView
	tagName: 'li'
	template: JST['item/o_course']
	events:
		"click .check": 'check'
		"click .make_open": 'open'
		"click .back": "back"
	initialize: ->
		@listenTo(@model, 'change', @render)
		@listenTo(@model, 'destroy', @remove)
	back: ->
		@$el.siblings().show()
		@model.set check: false
	check: ->
		@$el.siblings().hide()
		@model.set 
			check: true
	open: (e) ->
		@model.open =>
			@$el.siblings().show()
	render: ->
		status = 
			"1": "open"
			"2": "ready"
			"3": "draft"
		params = _.extend @model.toJSON(),stat: status[@model.get("status")]
		@$el.html @template(params)
		this