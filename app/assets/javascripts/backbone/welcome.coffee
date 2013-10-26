class window.Welcome
	constructor: ->
		$('body').addClass 'welcome'
		mixpanel.track("new visitor")
		setTimeout(->
			new Sound("imagine","mp3",true)
		,1500)
