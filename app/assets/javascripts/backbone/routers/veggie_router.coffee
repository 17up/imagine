#= require_self
#= require_tree ../collections/veggie
#= require_tree ../views/veggie

class Veggie.Router extends Backbone.Router  
	initialize: ->
		self = this
		new Veggie.BannerView()
		$("#side_nav").on "click","li", ->
			href = $(@).attr 'rel'
			if href is 'dashboard'
				href = ''
			self.navigate(href,true)
	routes:
		"": "home"
		"account": "account"
		"friend": "friend"
		"teach": "teach"
	before_change: ->
		if window.route.active_view
			window.route.active_view.close()
	home: ->
		@before_change()
		if @dashboard_view
			@dashboard_view.active()
		else
			@dashboard_view = new Veggie.DashboardView()
	account: ->
		@before_change()
		if @account_view
			@account_view.active()	
		else
			@account_view = new Veggie.AccountView()
	friend: ->
		@before_change()
		if @friend_view
			@friend_view.active()
		else
			@friend_view = new Veggie.FriendView()
	teach: ->
		@before_change()
		if @teach_view
			@teach_view.active()
		else
			@teach_view = new Veggie.TeachView()