class window.Veggie.TeachCourseView extends Marionette.ItemView
	tagName: 'li'
	className: ""
	template: JST['item/t_course']
	events:
		"click .edit": 'modify'
		"click .publish": 'publish'
		"click .save": "save"
		"click .fetch_words": "fetch_words"
		"click .select_words": "select_words"
		"click .delete": "delete"
		"click .back": "back"
		"mouseup .content": "handle_words"
		"click .select_words_view": "select_words_view"
	initialize: ->
		@listenTo(@model, 'change', @render)
		@listenTo(@model, 'destroy', @remove)
	deinit_imagine: ->
		window.route.active_view.deinit_imagine()
		$("#t_words").empty()
		@$el.removeClass 'opacity'
	back: ->
		@$el.siblings().show()
		@model.set editable: false
		@deinit_imagine()
	save: ->
		obj = $("form",@$el).serializeArray()
		serializedData = {}
		$.each obj, (index, field)->
			serializedData[field.name] = field.value
		if serializedData['content'] isnt '' and serializedData['title'] isnt ''
			# Utils.confirm "一旦保存，该课程中已编辑词汇将消失", =>
			Utils.loading @$el
			@model.save serializedData,success: (m,resp) =>
				data = _.extend resp.data, next: true
				@model.set data
				Utils.loaded @$el
		else
			Utils.flash "请确认课程标题及内容已填写","error"
	select_words_view: ->
		@$el.siblings().hide()
		Veggie.hide_nav()
		@model.set
			editable: true
			next: true
			fetch_word: false
		$("span.num",@$el).text @collect_words().length
		window.route.active_view.current_course = @model
	delete: ->
		Utils.confirm "确认删除？", =>
			@$el.siblings().show()
			@model.destroy()
			@deinit_imagine()
	modify: ->
		self = this
		@$el.siblings().hide()
		Veggie.hide_nav()
		@model.set
			editable: true
			next: false
		$form = $("form",@$el)
		Utils.tag_input($form)
		$('textarea',$form).css('overflow', 'hidden').autogrow()
		window.route.active_view.current_course = @model
	publish: (e) ->
		if $(@model.get("raw_content")).find("b")
			content = @model.get("raw_content")
			@model.ready content, =>
				@$el.siblings().show()
				@deinit_imagine()
		else
			Utils.flash "你还没有点选任何词汇呢，双击文本区域里的词汇试试吧","error"
	select_words: ->
		@deinit_imagine()
		@model.set
			editable: true
			next: true
			fetch_word: false
		$("span.num",@$el).text @collect_words().length
	addOneWord: (word,opts = {}) ->
		options = _.extend
			model: word
			opts
		view = new Veggie.TeachWordView options
		new_step = view.render().el
		$("#t_words").append(new_step)
	addEnd: (words_cnt) ->
		word = new Word
			tip: "老师辛苦啦，编辑完成咯，您的学生一定会很喜欢的～"
			num: words_cnt + 1
			end: "end"
		@addOneWord(word,id: "tend")
	addHome: (words_cnt) ->
		word = new Word
			tip: "～开始编辑词汇～"
			num: 0
			sum: words_cnt
		@addOneWord(word,id: "thome")
	collect_words: ->
		words = $(".content b",@$el)
		titles = _.map words,(b) ->
			$(b).text()
		_.uniq(titles)
	fetch_words: (e) ->
		words = @collect_words()
		if words.length > 0
			@addHome(words.length)
			for title,i in words
				word = new Word
					title: title
					num: i + 1
				@addOneWord word
			@addEnd(words.length)
			content = $.trim @$el.find(".content").html()
			@model.set
				raw_content: content
				editable: true
				next: true
				fetch_word: true
			window.route.active_view.init_imagine()
			@$el.addClass 'opacity'
		else
			Utils.flash "你还没有点选任何词汇呢，双击文本区域里的词汇试试吧","error"
	handle_words: ->
		if window.getSelection
			sel = window.getSelection()
			wl = sel.getRangeAt(0).toString().length
			if wl is 0
				# 选中光标前面的单词
				sel.modify('move','left','word')
				sel.modify('extend','right','word')
			else
				Utils.getSelection()
				$("span.num",@$el).text @collect_words().length
