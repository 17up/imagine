class window.Sound
	play: (looper = false) ->
    	if looper
    		window.sound.play
    			onfinish: =>
    				@play(true)
    	else
    		window.sound.play()
	constructor: (name,format = 'm4a',looper = false) ->
		id = "s_#{name}"
		url = "/audios/#{name}.#{format}"
		if window.sound and id is window.sound.id
			@play(looper)
		else
			window.sound = soundManager.createSound
	    		id: id
	    		url: url
	    		autoLoad: true
    		@play(looper)
    

