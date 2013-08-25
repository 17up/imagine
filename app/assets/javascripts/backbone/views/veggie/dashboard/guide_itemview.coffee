class window.Veggie.GuideView extends Marionette.ItemView
	tagName: 'div'
	className: ->
		if @model.get("num") and @model.get("num") isnt 1
			'asset alert alert-success hide'
		else
			'asset alert alert-success'
	template: JST['item/guide']
	events:
		"click .next": 'next'
		"click .start": 'start'
		"ajax:before #set_uid_form": "before_submit"
		"ajax:success #set_uid_form": "after_submit"
	@addOne: (guide,$wrap = $("#assets")) ->
		if guide
			view = new Veggie.GuideView
				model: guide
			$wrap.show().html(view.render().el)
	next: ->
		$next = @$el.next()
		$next.fadeIn()		
		@remove()
	start: ->
		window.route.active_view.render_member_view()
		@remove()
	before_submit: (e) ->
		Utils.loading $(e.currentTarget)
	after_submit: (e,data) ->
		if data.status is 0	
			@next()
			$("#side_nav li:first-child").siblings().show()
			$("nav .gem").text("10")
			mixpanel.track("new member")
		else
			Utils.flash(data.msg,"error")
		Utils.loaded $(e.currentTarget)