class window.Veggie.MissionView extends Marionette.ItemView
	tagName: 'div'
	className: 'step mission text_center'
	id: ->
		@model.get('title')
	attributes: ->
		"data-x": @model.get('num')*1500
		"data-y": 0
		"data-z": 0
		"data-scale": "1"
	template: JST['item/mission']
	events: ->
		"enterStep": "enterStep"
	initialize: ->
		@listenTo(@model, 'change', @render)
		@listenTo(@model, 'destroy', @remove)

	enterStep: (e) ->
		max = $("#imagine .step").length - 1
		percent = @model.get('num')*100/max
		$("#progress .current_bar").css "width": "#{percent}%"
