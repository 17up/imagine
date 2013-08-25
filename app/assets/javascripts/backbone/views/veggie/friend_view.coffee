class window.Veggie.FriendView extends Veggie.View
	id: "friend"
	className: "common"
	template: JST['friend_view']
	collection: new Veggie.Friend()
	render: ->
		template = @template(friend: @collection)
		@$el.html(template)
		this