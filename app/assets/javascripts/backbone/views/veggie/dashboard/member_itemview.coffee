class window.Veggie.MemberView extends Marionette.ItemView
	tagName: 'div'
	className: 'member'
	template: JST['item/member']
	initialize: ->
		@listenTo(@model, 'change', @render)


			
