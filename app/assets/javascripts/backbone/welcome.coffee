class window.Welcome
	constructor: ->
		$('body').addClass 'welcome'
		if _IE
			$(".sorry_tip").show()
		mixpanel.track("new visitor")
		setTimeout(->
			new Sound("imagine","mp3",true)
		,1500)
