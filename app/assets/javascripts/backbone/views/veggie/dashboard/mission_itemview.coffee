class window.Veggie.MissionView extends Marionette.ItemView
	tagName: 'div'
	className: 'step mission'
	id: ->
		@model.get('title')
	attributes: ->
		"data-x": @model.get('num')*1000
		"data-y": 0
		"data-z": -@model.get('num')*1000	
		"data-scale": "1"
	template: JST['item/mission']
	events: ->
		"enterStep": "enterStep"
		"leaveStep": "leaveStep"
	initialize: ->
		#@listenTo(@model, 'change', @render)
		@listenTo(@model, 'destroy', @remove)

	enterStep: (e) ->
		max = ($("#imagine .step").length+1)/3
		percent = @model.get('num')*100/max
		$("#progress .current_bar").css "width": "#{percent}%"
		#$("footer #uploader .uword input[name='_id']").val @model.get("_id")
	upload_img: (e) ->
		Utils.uploader $(e.currentTarget),(img) =>
			$(".medias .image img",@$el).attr "src",img