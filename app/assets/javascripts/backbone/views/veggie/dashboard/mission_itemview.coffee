class window.Veggie.MissionView extends Marionette.ItemView
	tagName: 'div'
	className: 'step mission text_center'
	id: ->
		@model.get('title')
	attributes: ->
		"data-x": @model.get('num')*1500
		"data-y": 0
		"data-z": -@model.get('num')*1000
		"data-scale": "1"
	template: JST['item/mission']
	events: ->
		"enterStep": "enterStep"
		"leaveStep": "leaveStep"
		"click .upload_img": "upload_img"
	initialize: ->
		@listenTo(@model, 'change', @render)
		@listenTo(@model, 'destroy', @remove)

	enterStep: (e) ->
		max = $("#imagine .step").length - 1
		percent = @model.get('num')*100/max
		$("#progress .current_bar").css "width": "#{percent}%"
		$("footer #uploader .uword input[name='_id']").val @model.get("_id")
	upload_img: (e) ->
		Utils.uploader $(e.currentTarget),(img) =>
			@model.set u_word_image: img
			# $(".medias .image img",@$el).attr "src",img
