class window.Veggie.ProviderView extends Marionette.ItemView
	tagName: 'div'
	className: 'step provider'
	id: ->
		@model.get('provider')
	attributes: ->
		"data-x": @model.get('num')*1500
		"data-y": 0
		"data-z": 0	
		"data-scale": "1"
	template: JST['item/provider']
	events: ->
		"enterStep": "enterStep"
	initialize: ->
		@listenTo(@model, 'change', @render)
	enterStep: ->
		@model.fetch =>
			$(".container",@$el).fadeIn()
		this