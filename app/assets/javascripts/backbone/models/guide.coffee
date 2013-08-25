class window.Guide extends Backbone.Model
	defaults:
		"emotion": 'sweet'
		"text": ''
	@generate: (text,num = null,em = 'sweet') ->
		new Guide
			emotion: em
			text: text
			num: num
	@courses: (sense) ->		
		key = "courses_#{sense}"
		if guides = $.jStorage.get key
			guide = Guide.generate guides
			$.jStorage.deleteKey key
			guide
		else
			false
	@fetch: (guides) ->
		ele = ["courses","imagine"]
		for e in ele
			for i in _.keys(guides[e])
				$.jStorage.set "#{e}_#{i}",guides[e][i]
	@imagine: (sense) ->		
		key = "imagine_#{sense}"
		if guides = $.jStorage.get key
			guide = Guide.generate guides,null,'reward'
			$.jStorage.deleteKey key
			guide
		else
			false

	