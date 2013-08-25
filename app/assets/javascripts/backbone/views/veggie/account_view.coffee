class window.Veggie.AccountView extends Veggie.View	
	id: "account"
	template: JST['account_view']
	model: new Veggie.Account()
	close: ->
		if $("#account_wrap").jmpress("initialized")
			$("#account_wrap").jmpress "deinit"
		super()
		# invoke super close method
	active: ->
		# 调用父类的active方法 
		# 等同于 Veggie.View.prototype.active.apply(this, arguments)
		super() 
		@init_jmpress()
	init_jmpress: ->
		unless $("#account_wrap").jmpress("initialized")
			$("#account_wrap").jmpress
				transitionDuration: 0
				hash:
					use: true
				mouse:
					clickSelects: false
				keyboard:
					keys:
						9: null
						32: null
	addProviders: (providers) ->
		for p,i in providers
			provider = new Provider
				provider: p.provider
				num: i + 1
			view = new Veggie.ProviderView
				model: provider
			$("#account_wrap").append(view.render().el)
	extra: ->
		providers = _.filter @model.get("providers"),(p) ->
			p if p.has_bind
		@addProviders providers
		super()