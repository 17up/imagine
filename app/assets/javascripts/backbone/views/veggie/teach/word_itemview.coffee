class window.Veggie.TeachWordView extends Marionette.ItemView
	className: "t_word"
	template: JST['item/t_word']
	id: ->
		@model.get('title')
	attributes: ->
		"data-x": @model.get('num')*1500
		"data-y": 0
		"data-z": 0
		"data-scale": "1"
	events:
		"enterStep": "enterStep"
		"leaveStep": "leaveStep"
		"ajax:success .word_form": "after_submit"

	initialize: ->
		@listenTo(@model, 'change', @render)
	load: ->
		$btn = $(".load",@$el)
		unless $btn.hasClass "loading"
			$btn.addClass "loading"
			Utils.loading $btn
			$("span",$btn).addClass 'icon-spin'
			@model.fetch =>
				$form = $(".word_form",@$el)
				Utils.tag_input $form
	enterStep: (e) ->
		max = $("#t_words .t_word").length - 1
		percent = @model.get('num')*100/max
		$("#t_progress .current_bar").css "width": "#{percent}%"
		if @model.get("title") isnt '' and @model.get("content") is ''
			@load()
	leaveStep: (e) ->
		if @model.get("title") isnt ''
			$form = $(".word_form",@$el)
			synset_val = $("input[name='synset']",$form).val()
			sentence_val = $("input[name='sentence']",$form).val()
			unless (synset_val is @model.get("synset").join(",")) and (sentence_val is @model.get("sentence").join("~"))
				$form.submit()
	after_submit: (e,data) ->
		if data.status is 0
			@model.set data.data,silent: true