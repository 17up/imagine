class window.Olive.QuotesView extends Olive.View
	id: 'quotes'
	className: "block"
	template: JST['quotes_view']
	collection: new Olive.Quote()
	events: ->
		"click .as_link": "remove_tag"
		"ajax:before form": "before_submit"
		"ajax:success #cq_form": "cq_success"
		"ajax:success #sq_form": "sq_success"
	remove_tag: (e) ->
		tag_name = $.trim $(e.currentTarget).text()
		$ele = $(e.currentTarget).parent()
		Utils.confirm "确认删除？", ->
			$.post "/olive/destroy_tag",tag: tag_name, (d) ->
				if d.status is 0
					$ele.remove()
					Utils.flash("#{d.data} removed")
	before_submit: (e) ->
		$form = $(e.currentTarget)
		Utils.loading $form
	cq_success: (e,data) ->
		$form = $(e.currentTarget)
		if data.status is 0		
			Utils.flash(data.msg)
			$form[0].reset()
			Utils.loaded $form
	sq_success: (e,data) ->
		$form = $(e.currentTarget)
		$query = $("input[type='text']",$form).val()
		if data.status is 0		
			$("#quote_list").html JST['collection/quotes'](quotes: data.data.quotes,query: $query)
			$form[0].reset()
			Utils.loaded $form
	render: ->
		template = @template(tags: @collection.get('tags'))
		@$el.html(template)				
		this