class window.Veggie.Members extends Backbone.Collection
	model: Member
	addOneMember: (member) ->
		view = new Veggie.MemberView
			model: member 
		$("#oline_users").append(view.render().el)
	push: (member) ->
		super(member)
		@addOneMember(member)